# OxCapsule (First Time) Download & Installation Guide

**Note: If you are updating capsule, please use the `capsule update` command to download the latest cli version**

## Download
Users should use the link provided in the email to download the OxCaspule v0.2.29 zip file
Extract the contents of the zip file

## Installation

### System Requirements

#### Windows
- Windows 10 or later (Windows 10 version 1803+ for built-in tar support)
- PowerShell 5.1 or later
- Administrator privileges (required for installation to Program Files)

#### macOS
- macOS 10.15 (Catalina) or later
- Terminal access
- Administrator privileges (for /usr/local installation)

### Windows Installation

Make sure `install-oxcapsule-win.ps1` and `capsule-cli-0.2.29-win-x64-public.tar.gz` are in the same directory (e.g. Downloads). Navigate to that directory in an Administrator Powershell window, then run:

```powershell
Unblock-File -Path .\install-oxcapsule-win.ps1
.\install-oxcapsule-win.ps1
Go through the installation steps
Press Y when prompted for symlink creation
```

This will:
1. Extract and Install OxCapsule
2. Install to `C:\Program Files\Capsule-CLI``
3. Add Capsule to PATH
4. Verify the Installation

### macOS Installation

Make sure `install-oxcapsule-osx.sh` and `capsule-cli-0.2.29-osx-arm64-public.gz` are in the same directory (e.g. Downloads). Navigate to that directory in a terminal window then run:

```bash
chmod +x install-oxcapsule-osx.sh
./install-oxcapsule-osx.sh
Go through the installation steps
Press Y when prompted for symlink creation
```

This will:
1. Extract the OxCapsule CLI
2. Install to `/usr/local/capsule-cli`
3. Create system-wide symlink
4. Verify the installation

If the project continually asks for permission to run the application, run `sudo xattr -r -d com.apple.quarantine /usr/local/capsule-cli/bin/*` for permission issues

### Linux Installation

Make sure `install-oxcapsule-linux.sh` and `capsule-cli-0.2.29-linux-x64-public.gz` are in the same directory. Navigate to that directory in a terminal window then run:

```bash
# Install dependencies
sudo apt install libgl1 libglu1 libxdamage1 libva2 libva-drm2 libva-x11-2 libvdpau1
chmod +x install-oxcapsule-linux.sh
./install-oxcapsule-linux.sh
# Go through the installation steps
Press Y when prompted for symlink creation
```

This will:
1. Extract the OxCapsule CLI
2. Install to `/usr/local/capsule-cli`
3. Create system-wide symlink
4. Verify the installation

## Troubleshooting

### Installation Issues

#### Windows
- **PATH not updated**: Open a new terminal window after installation
- **Access denied**: Run PowerShell as Administrator
- **Missing files**: Verify `C:\Program Files\Capsule-CLI\bin\capsule.exe` exists

#### macOS
- **Permission denied**: Run `sudo chmod +x /usr/local/capsule-cli/bin/capsule`
- **Command not found**: Verify symlink with `ls -la /usr/local/bin/capsule`
- **Persistent blocking**: Remove quarantine with `sudo xattr -r -d com.apple.quarantine /usr/local/capsule-cli/bin/*`

### Common Usage Issues

1. **Authentication Failures**
   - Ensure you're logged in: `capsule auth login`
   - Check network connectivity
   - Verify your credentials are valid

2. **Configuration Tag Not Found**
   - Run `capsule list` to see available configuration tags

3. **Connection Issues**
   - Verify network connectivity to remote servers
   - Check firewall settings
   - Check whether your internet is behind a CGNAT or a symmetric NAT. If so, capsule connections will not succeed. We are developing a solution for this issue.
   - If on Linux, please download the following packages:
   ```
      sudo apt install libgl1 libglu1 libxdamage1 libva2 libva-drm2 libva-x11-2 libvdpau1
   ```
   - If experiencing issues reconnecting to a machine, run `capsule cleanup`.
      **Note: When logged into another machine, this command will terminate active concurrent sessions.**
      After running `capsule cleanup`, please wait 30 seconds before attempting to reconnect.
   - 

4. **MacOS prompt to "Allow Keychain Access"**
   - Your authentication token needs to be stored securely in Apple's vault.
   - Enter yur system password and click "Always Allow" to allow OxCapsule to safely store credentials on your system.

5. **Mounting a Personal OneDrive**
   - Open a docker container on remote machine
   - Run this command to setup docker: `docker run -v ~/OneDrive:/OneDrive -it ubuntu`

6. **Failed update**
   - Updates will fail on Windows machines when a session is active. When this occurs, please reinstall capsule with the latest manual official package. This will clear up issues with the capsule installation.

7. **In a mount, git shows all files as executable**
   - If doing dev work in a UserStorage or OneDrive mount, the setting `git config core.fileMode false` must be run. Mounts will automatically set every file and folder to executable; this is immutable. Set git to ignore file perm changes in the git diff. 

### Log Files

For additional debugging, check the log files located at:

- **Windows**: `%APPDATA%\capsule\logs`
- **macOS**: `~/Library/Application Support/capsule/logs`
- **Linux** `$HOME/.config/capsule/logs/`
