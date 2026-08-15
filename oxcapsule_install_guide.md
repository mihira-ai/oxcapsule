# OxCapsule (First Time) Download & Installation Guide

**Note: If you already have capsule downloaded and wish to download the latest version, please use the `capsule update` command to download the latest cli version**

## Download
Users should use the provided scripts for [Windows](./install.ps1) and [Linux/Mac](./install.sh) to automatically download the latest version of capsule.

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

1. Download the [Windows install script](./install.ps1). 
2. In an Administrator PowerShell window, navigate to the path of the script
3. Run `Set-ExecutionPolicy -Scope Process Bypass -Force; .\install.ps1`
4. Follow the interactive instructions. Press Y when prompted to add Capsule to your path.

### macOS/Linux Installation

1. Download the [Linux/Mac install script](./install.sh). 
2. Navigate to the path of the script. Run `chmod +x install.sh`.
3. Run `./install.sh`.
4. Follow the interactive instructions. Press Y when prompted to add Capsule to your path and to create a symlink.

## Troubleshooting

Below is a list of common OxCapsule installation issues. Refer to the [troubleshooting guide](./troubleshooting_guide.md) for other issues.

### Installation Issues

#### Windows
- **PATH not updated**: Open a new terminal window after installation
- **Access denied**: Run PowerShell as Administrator
- **Missing files**: Verify `C:\Program Files\Capsule-CLI\bin\capsule.exe` exists

#### macOS
- **Permission denied**: Run `sudo chmod +x /usr/local/capsule-cli/bin/capsule`
- **Command not found**: Verify symlink with `ls -la /usr/local/bin/capsule`
- **Persistent blocking**: Remove quarantine with `sudo xattr -r -d com.apple.quarantine /usr/local/capsule-cli/bin/*`