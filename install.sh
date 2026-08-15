#!/bin/bash
set -e

# Capsule CLI Installer for macOS and Linux
# Usage: curl -fsSL https://raw.githubusercontent.com/oxmiq/oxcapsule/main/install.sh | bash
#        bash <(curl -fsSL https://raw.githubusercontent.com/oxmiq/oxcapsule/main/install.sh)
#        ./install.sh

# ── Configuration ────────────────────────────────────────────────
CAPSULE_VERSION="0.5.53"
RELEASE_REPO="oxmiq/oxcapsule"
DOWNLOAD_URL="https://github.com/${RELEASE_REPO}/releases/download/v${CAPSULE_VERSION}/capsule-cli-install-${CAPSULE_VERSION}.zip"
INSTALL_DIR="/usr/local/capsule-cli"
SYMLINK_DIR="/usr/local/bin"

# ── Colors ───────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# ── Helpers ──────────────────────────────────────────────────────
info()    { printf "${BLUE}${BOLD}==>${NC} ${BOLD}%s${NC}\n" "$1"; }
success() { printf "${GREEN}${BOLD}==>${NC} ${BOLD}%s${NC}\n" "$1"; }
warn()    { printf "${YELLOW}Warning:${NC} %s\n" "$1"; }
error()   { printf "${RED}Error:${NC} %s\n" "$1" >&2; exit 1; }

cleanup() {
    if [ -n "${TEMP_DIR:-}" ] && [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}
trap cleanup EXIT

# ── Privilege helper ─────────────────────────────────────────────
if [ "$(id -u)" = "0" ]; then
    SUDO=""
else
    SUDO="sudo"
fi

# ── Prompt helpers ───────────────────────────────────────────────
prompt_with_default() {
    local prompt="$1" default="$2" var_name="$3" response
    printf "%s [${GREEN}%s${NC}]: " "$prompt" "$default"
    read -r response </dev/tty
    if [ -z "$response" ]; then
        eval "$var_name='$default'"
    else
        eval "$var_name='$response'"
    fi
}

prompt_yes_no() {
    local prompt="$1" default="$2" prompt_text response
    if [ "$default" = "y" ]; then
        prompt_text="${prompt} [Y/n]: "
    else
        prompt_text="${prompt} [y/N]: "
    fi
    printf "%s" "$prompt_text"
    read -r response </dev/tty
    [ -z "$response" ] && response="$default"
    [[ "$response" =~ ^[Yy]$ ]]
}

# ── Pre-22.04 Ubuntu check ───────────────────────────────────────
is_pre_2204() {
    local version="$1"
    [ -z "$version" ] && return 1
    [ "$version" != "22.04" ] && printf '%s\n' "$version" "22.04" | sort -V -C
}

# ── Ubuntu version detection ─────────────────────────────────────
# /etc/os-release is always present; lsb_release is not installed on minimal images
# Only Ubuntu reports a version — the 22.04 split and package names are Ubuntu specific
detect_os_version() {
    local id="" version=""

    if [ -r /etc/os-release ]; then
        id=$(. /etc/os-release 2>/dev/null; printf '%s' "${ID:-}")
        version=$(. /etc/os-release 2>/dev/null; printf '%s' "${VERSION_ID:-}")
    fi

    if [ -z "$version" ] && command -v lsb_release &>/dev/null; then
        id=$(lsb_release -is 2>/dev/null | tr '[:upper:]' '[:lower:]')
        version=$(lsb_release -rs 2>/dev/null)
    fi

    if [ "$id" = "ubuntu" ]; then
        printf '%s' "$version"
    fi
    return 0
}

# ── Platform detection ───────────────────────────────────────────
detect_platform() {
    OS="$(uname -s)"
    ARCH="$(uname -m)"

    case "$ARCH" in
        x86_64|amd64)  ARCH_SUFFIX="x64" ;;
        arm64|aarch64) ARCH_SUFFIX="arm64" ;;
        *) error "Unsupported architecture: $ARCH" ;;
    esac

    case "$OS" in
        Darwin)
            PLATFORM="osx"
            if [ "$ARCH_SUFFIX" = "x64" ]; then
                error "macOS Intel (x86_64) is not supported. Only Apple Silicon (arm64) is available."
            fi
            ;;
        Linux) PLATFORM="linux" ;;
        *) error "Unsupported operating system: $OS. This installer supports macOS and Linux." ;;
    esac
}

# ── Tarball selection ────────────────────────────────────────────
select_tarball() {
    if [ "$PLATFORM" = "osx" ]; then
        TAR_PATTERN="capsule-cli-${CAPSULE_VERSION}-osx-arm64.tar.gz"
    elif [ "$PLATFORM" = "linux" ]; then
        if [ "$ARCH_SUFFIX" = "arm64" ]; then
            TAR_PATTERN="capsule-cli-${CAPSULE_VERSION}-linux-arm64.tar.gz"
        elif is_pre_2204 "$OS_VERSION"; then
            TAR_PATTERN="capsule-cli-${CAPSULE_VERSION}-linux-x64-22.04.tar.gz"
        else
            TAR_PATTERN="capsule-cli-${CAPSULE_VERSION}-linux-x64.tar.gz"
        fi
    fi
}

# ── Dependency check ─────────────────────────────────────────────
check_dependencies() {
    for cmd in curl unzip tar; do
        command -v "$cmd" &>/dev/null \
            || error "'$cmd' is required but not installed. Please install it and try again."
    done
}

# ── Linux runtime deps ───────────────────────────────────────────
install_linux_deps() {
    local packages

    if is_pre_2204 "$OS_VERSION"; then
        packages="libgl1-mesa-glx libglu1-mesa libxdamage1 libva2 libva-drm2 libva-x11-2 libvdpau1"
    else
        packages="libgl1 libglu1 libxdamage1 libva2 libva-drm2 libva-x11-2 libvdpau1"
    fi

    if ! command -v apt &>/dev/null; then
        warn "apt not found. You may need to manually install: ${packages}"
        return
    fi

    local missing=""
    for dep in $packages; do
        dpkg -s "$dep" &>/dev/null 2>&1 || missing="${missing} ${dep}"
    done

    if [ -n "$missing" ]; then
        $SUDO apt update -qq && $SUDO apt install -y -qq $missing \
            || warn "Some dependencies could not be installed. You may need to run: sudo apt install ${packages}"
    fi
}

# ── rclone dependency ────────────────────────────────────────────
install_rclone() {
    local manual="Please install rclone manually: https://rclone.org/install/"

    if [ "$PLATFORM" = "osx" ]; then
        if ! command -v brew &>/dev/null; then
            warn "Homebrew is not available. ${manual}"
            return
        fi
        info "Installing rclone..."
        brew install rclone \
            && success "rclone installed" \
            || warn "Could not install rclone automatically. ${manual}"
        return
    fi

    if ! command -v apt &>/dev/null; then
        warn "apt not found. ${manual}"
        return
    fi

    info "Installing rclone..."
    $SUDO apt update -qq && $SUDO apt install -y -qq rclone \
        && success "rclone installed" \
        || warn "Could not install rclone automatically. ${manual}"
}

# ── Main ─────────────────────────────────────────────────────────
main() {
    echo ""
    printf "${GREEN}${BOLD}  Capsule CLI Installer v${CAPSULE_VERSION}${NC}\n"
    echo "  =================================="
    echo ""

    detect_platform

    # Capture Ubuntu version early — used by both select_tarball and install_linux_deps
    OS_VERSION=""
    if [ "$PLATFORM" = "linux" ]; then
        OS_VERSION=$(detect_os_version)
    fi

    select_tarball
    check_dependencies

    info "Detected platform: ${PLATFORM}-${ARCH_SUFFIX}"

    # Download
    TEMP_DIR="$(mktemp -d)"
    info "Downloading Capsule CLI v${CAPSULE_VERSION}..."
    curl -fSL --http1.1 --progress-bar -o "${TEMP_DIR}/capsule-install.zip" "$DOWNLOAD_URL" \
        || error "Failed to download from ${DOWNLOAD_URL}"

    info "Extracting package..."
    unzip -q "${TEMP_DIR}/capsule-install.zip" -d "${TEMP_DIR}" \
        || error "Failed to extract zip archive"

    TAR_FILE=$(find "${TEMP_DIR}" -name "$TAR_PATTERN" -type f | head -1)
    if [ -z "$TAR_FILE" ]; then
        error "Could not find ${TAR_PATTERN} in the downloaded package. Your platform (${PLATFORM}-${ARCH_SUFFIX}) may not be supported in v${CAPSULE_VERSION}."
    fi

    info "Extracting ${TAR_PATTERN}..."
    tar -xzf "$TAR_FILE" -C "${TEMP_DIR}" \
        || error "Failed to extract ${TAR_PATTERN}"

    [ -d "${TEMP_DIR}/bin" ] || error "Expected 'bin' directory not found after extraction"

    # Step 0 (Linux only): runtime dependencies
    if [ "$PLATFORM" = "linux" ]; then
        echo ""
        echo "Step 0: Runtime dependencies"
        if [ -n "$OS_VERSION" ]; then
            info "Detected Ubuntu ${OS_VERSION}"
        fi
        if prompt_yes_no "Install required system libraries (libgl1, libva2, etc.)?" "y"; then
            install_linux_deps
        fi
    fi

    # Step 1: installation location
    echo ""
    echo "Step 1: Installation location"
    prompt_with_default "Installation directory" "$INSTALL_DIR" "INSTALL_DIR"

    if [ -d "$INSTALL_DIR" ]; then
        warn "Installation directory already exists: $INSTALL_DIR"
        if prompt_yes_no "Overwrite existing installation?" "n"; then
            $SUDO rm -rf "$INSTALL_DIR" || error "Failed to remove existing installation"
        else
            error "Installation cancelled."
        fi
    fi

    # Step 2: install files
    echo ""
    echo "Step 2: Installing files to $INSTALL_DIR..."
    $SUDO mkdir -p "$INSTALL_DIR" || error "Failed to create ${INSTALL_DIR}"
    $SUDO cp -R "${TEMP_DIR}/bin" "${INSTALL_DIR}/" || error "Failed to copy files"
    $SUDO chmod +x "${INSTALL_DIR}/bin/capsule" || error "Failed to set executable permissions"

    if [ "$PLATFORM" = "osx" ]; then
        info "Removing macOS quarantine attributes..."
        $SUDO xattr -r -d com.apple.quarantine "${INSTALL_DIR}/bin/" 2>/dev/null || true
    fi

    # Step 3: symlinks
    echo ""
    echo "Step 3: Symlink configuration"
    SYMLINK_PATH=""
    CAP_PATH=""

    if prompt_yes_no "Create symlinks for system-wide access (capsule and cap commands)?" "y"; then
        prompt_with_default "Symlink directory" "$SYMLINK_DIR" "SYMLINK_DIR"
        $SUDO mkdir -p "$SYMLINK_DIR"

        SYMLINK_PATH="${SYMLINK_DIR}/capsule"
        CAP_PATH="${SYMLINK_DIR}/cap"

        if [ -e "$SYMLINK_PATH" ] || [ -e "$CAP_PATH" ]; then
            [ -e "$SYMLINK_PATH" ] && warn "File already exists at $SYMLINK_PATH"
            [ -e "$CAP_PATH" ] && warn "File already exists at $CAP_PATH"
            if prompt_yes_no "Overwrite existing symlinks?" "n"; then
                [ -e "$SYMLINK_PATH" ] && $SUDO rm -f "$SYMLINK_PATH"
                [ -e "$CAP_PATH" ] && $SUDO rm -f "$CAP_PATH"
            else
                warn "Skipping symlink creation"
                SYMLINK_PATH=""
                CAP_PATH=""
            fi
        fi

        if [ -n "$SYMLINK_PATH" ]; then
            $SUDO ln -sf "${INSTALL_DIR}/bin/capsule" "$SYMLINK_PATH" \
                || error "Failed to create symlink for 'capsule'"
            if [ -f "${INSTALL_DIR}/bin/cap" ]; then
                $SUDO ln -sf "${INSTALL_DIR}/bin/cap" "$CAP_PATH"
            else
                $SUDO ln -sf "${INSTALL_DIR}/bin/capsule" "$CAP_PATH"
            fi
        fi
    else
        warn "Skipping symlink creation"
    fi

    # Step 4: rclone dependency
    echo ""
    echo "Step 4: Dependencies"
    if ! command -v rclone &>/dev/null; then
        if prompt_yes_no "Install rclone (required for storage features)?" "y"; then
            install_rclone
        else
            warn "Skipping rclone installation"
        fi
    fi

    # Summary
    echo ""
    success "Installation completed successfully!"
    echo ""
    echo "  Installation summary:"
    echo "    Installed to: $INSTALL_DIR"
    if [ -n "$SYMLINK_PATH" ]; then
        echo "    Symlinks:     ${SYMLINK_DIR}/capsule, ${SYMLINK_DIR}/cap"
        echo ""
        echo "  You can now use 'capsule' or 'cap' from anywhere in your terminal."
    else
        echo "    No symlinks created"
        echo ""
        echo "  To use capsule, run: $INSTALL_DIR/bin/capsule"
    fi

    echo ""
    echo "  Verifying installation..."
    if command -v capsule &>/dev/null; then
        success "capsule command is available in your PATH"
    elif [ -x "${INSTALL_DIR}/bin/capsule" ]; then
        success "Capsule executable found at ${INSTALL_DIR}/bin/capsule"
        warn "You may need to open a new terminal for the 'capsule' command to be available."
    else
        warn "Could not verify installation. Check ${INSTALL_DIR}/bin/capsule"
    fi

    printf "\n"
    printf "  Get started:\n"
    printf "    ${BOLD}capsule auth login${NC}      Log in to your account\n"
    printf "    ${BOLD}capsule list${NC}            List available servers\n"
    printf "    ${BOLD}capsule --help${NC}          Show all commands\n"
    printf "\n"
}

main "$@"
