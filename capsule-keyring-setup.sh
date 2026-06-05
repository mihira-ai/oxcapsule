#!/usr/bin/env bash
#
# capsule-keyring-setup.sh
#
# Prepares a Linux system so capsule's MSAL token storage works on headless
# SSH/TTY sessions. Idempotent: safe to run repeatedly. Detects working
# keyrings and leaves them alone; only mutates state when actually broken.
#
# States handled:
#   - No keyring installed       -> installs packages, initializes, unlocks
#   - Already working keyring    -> verifies and exits cleanly, no changes
#   - Broken/locked keyring      -> reinitializes with empty-password unlock
#   - Real password-protected    -> detected and left alone (will not destroy)

set -euo pipefail

readonly REQUIRED_PACKAGES=(
    libsecret-1-0      # client library capsule dlopens at runtime
    libsecret-tools    # provides secret-tool for diagnostics/test
    gnome-keyring      # the Secret Service daemon
    dbus-user-session  # ensures per-user D-Bus session bus on login
)

readonly KEYRING_DIR="$HOME/.local/share/keyrings"
readonly EMPTY_KEYRING_MAX_BYTES=200  # login.keyring is ~105 bytes when empty
readonly USER_DBUS_SERVICES_DIR="$HOME/.local/share/dbus-1/services"
readonly SECRETS_OVERRIDE="$USER_DBUS_SERVICES_DIR/org.freedesktop.secrets.service"
readonly KEYRING_OVERRIDE="$USER_DBUS_SERVICES_DIR/org.gnome.keyring.service"

log()  { printf '[keyring-setup] %s\n' "$*"; }
warn() { printf '[keyring-setup] WARN: %s\n' "$*" >&2; }
die()  { printf '[keyring-setup] ERROR: %s\n' "$*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# Sanity
# ---------------------------------------------------------------------------
[ "$(id -u)" != "0" ] || die "Run as the target user, not root (keyring is per-user). sudo is invoked internally for apt."
command -v apt-get >/dev/null || die "This script targets apt-based systems (Debian/Ubuntu)."

# ---------------------------------------------------------------------------
# 1. Install missing apt packages
# ---------------------------------------------------------------------------
missing=()
for pkg in "${REQUIRED_PACKAGES[@]}"; do
    dpkg -s "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
done

if [ ${#missing[@]} -gt 0 ]; then
    log "Installing missing packages: ${missing[*]}"
    sudo apt-get update -qq
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${missing[@]}"
else
    log "All required packages already installed."
fi

# ---------------------------------------------------------------------------
# 2. Ensure a D-Bus session bus is reachable
# ---------------------------------------------------------------------------
if [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
    candidate="/run/user/$(id -u)/bus"
    if [ -S "$candidate" ]; then
        export DBUS_SESSION_BUS_ADDRESS="unix:path=$candidate"
        log "Using D-Bus session at $DBUS_SESSION_BUS_ADDRESS"
    else
        die "No D-Bus session bus (no \$DBUS_SESSION_BUS_ADDRESS and $candidate missing). Log out and back in so systemd starts the user session, or install dbus-user-session and try again."
    fi
fi

# Confirm we can talk to the session bus at all.
dbus-send --session --print-reply --dest=org.freedesktop.DBus / \
    org.freedesktop.DBus.ListNames >/dev/null 2>&1 \
    || die "D-Bus session bus address is set but unreachable."

# ---------------------------------------------------------------------------
# 3. Test current keyring functionality via write/read round-trip
# ---------------------------------------------------------------------------
keyring_works() {
    local val
    timeout 5 secret-tool store --label='capsule-keyring-probe' \
        application capsule-keyring-setup probe value <<<'ok' \
        >/dev/null 2>&1 || return 1
    val=$(timeout 5 secret-tool lookup application capsule-keyring-setup probe value 2>/dev/null) || return 1
    timeout 5 secret-tool clear application capsule-keyring-setup probe value >/dev/null 2>&1 || true
    [ "$val" = "ok" ]
}

if keyring_works; then
    log "Keyring is already functional (write/read round-trip succeeded). No changes needed."
    exit 0
fi

log "Keyring is not functional. Diagnosing before making changes..."

# ---------------------------------------------------------------------------
# 4. Refuse to wipe a password-protected keyring with real content.
#    A truly empty/headless login.keyring is ~105 bytes. Anything substantially
#    larger likely has real secrets we must not destroy.
# ---------------------------------------------------------------------------
if [ -f "$KEYRING_DIR/login.keyring" ]; then
    size=$(stat -c '%s' "$KEYRING_DIR/login.keyring")
    if [ "$size" -gt "$EMPTY_KEYRING_MAX_BYTES" ]; then
        die "$KEYRING_DIR/login.keyring is $size bytes — appears to contain real secrets and is locked. Refusing to wipe. Unlock it manually with its password, or delete it explicitly if you are sure."
    fi
fi

# ---------------------------------------------------------------------------
# 5. Install user-level D-Bus service overrides.
#
#    gnome-keyring is D-Bus auto-activated on every Ubuntu we care about. The
#    system .service files run the daemon WITHOUT --unlock, so the collection
#    stays locked and writes fail in headless sessions. User-level service
#    files at ~/.local/share/dbus-1/services/ take precedence over the system
#    ones for that user, so we override them to pipe an empty password into
#    --unlock on every activation. 'echo' supplies the required trailing
#    newline; 'printf ""' alone does not unlock.
# ---------------------------------------------------------------------------
mkdir -p "$USER_DBUS_SERVICES_DIR"

# Helper: D-Bus Exec= parses arguments like execv; it doesn't run a shell.
# We need stdin to be a newline (empty password) for --unlock to work, so we
# wrap in /bin/sh -c with a pipe. NOTE: /bin/sh on Ubuntu is dash, which does
# NOT support bash's <<< here-string — use 'echo | exec ...' instead.
write_override() {
    local path="$1" bus_name="$2" components="$3"
    cat > "$path" <<EOF
[D-BUS Service]
Name=$bus_name
Exec=/bin/sh -c "echo | exec /usr/bin/gnome-keyring-daemon --foreground --components=$components --unlock"
EOF
}

log "Installing D-Bus user-service overrides with --unlock at $USER_DBUS_SERVICES_DIR/"
write_override "$SECRETS_OVERRIDE" "org.freedesktop.secrets" "secrets"
write_override "$KEYRING_OVERRIDE" "org.gnome.keyring"     "secrets,pkcs11,ssh"

# ---------------------------------------------------------------------------
# 6. Kill every running gnome-keyring-daemon so D-Bus re-activates fresh
#    using our overrides on the next call.
# ---------------------------------------------------------------------------
log "Killing all gnome-keyring-daemon processes to force re-activation via the overrides."
systemctl --user stop gnome-keyring-daemon.service gnome-keyring-daemon.socket 2>/dev/null || true
pkill -u "$USER" -x gnome-keyring-daemon 2>/dev/null || true
pkill -u "$USER" -f 'gnome-keyring-daemon' 2>/dev/null || true
sleep 1

# Tell the session bus to reload service files so our overrides take effect now.
dbus-send --session --type=method_call --dest=org.freedesktop.DBus \
    /org/freedesktop/DBus org.freedesktop.DBus.ReloadConfig 2>/dev/null || true

# ---------------------------------------------------------------------------
# 7. Trigger D-Bus auto-activation by issuing a real write/read and verify.
# ---------------------------------------------------------------------------
sleep 1
if ! keyring_works; then
    warn "Keyring still not functional after overrides installed. Trying recovery: wipe the empty keyring and retry."
    pkill -u "$USER" -f 'gnome-keyring-daemon' 2>/dev/null || true
    sleep 1
    rm -f "$KEYRING_DIR/login.keyring" "$KEYRING_DIR/user.keystore"
    sleep 1
    keyring_works || die "Keyring still not functional. Confirm the override took effect:
  cat $SECRETS_OVERRIDE
  pgrep -u \$USER -fa gnome-keyring
  secret-tool store --label=probe app k v <<< ok"
fi

log "Keyring is now functional (verified by write/read round-trip)."
log "D-Bus will auto-activate the unlocked daemon for every future session — no .bash_profile changes needed."
log "Done. Test with: capsule auth login && capsule status"
