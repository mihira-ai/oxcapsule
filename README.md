![capsule 2](https://github.com/user-attachments/assets/b358529d-c4ba-439d-850e-80f7501a29b7)

OxCapsule is a CLI tool that instantly connects you to high-performance remote machines for development, training models, running containers, and more. Stop worrying about local hardware limitations—work with the compute you need, when you need it.

[Latest Release Notes](./Release_notes.md)

## Why OxCapsule?
- **Instant Access**: Connect to GPU/CPU clusters in seconds, not hours
- **Your Tools, Remote Power**: Use VS Code, Cursor, or SSH with remote machines seamlessly
- **Flexible Compute**: From lightweight testing to 128GB+ GPU workstations
- **Zero Setup**: No infrastructure management, no complex configurations

## Download
OxCapsule is currently provided as public beta only with invites. Users will be receiving email after the access is approved and will require to follow the steps in the email to download the OxCapsule client

## Installation
**Note: If you are updating capsule, please use the `capsule update` command to download the latest cli version**

For detailed platform specific installation steps and screenshots. Refer to [oxcapsule/oxcapsule_intall_guide.md](https://github.com/mihira-ai/oxcapsule/blob/main/oxcapsule_install_guide.md)

## First Time Authentication
Users need to authenticate and validate their email address used for the beta access, set password for the authentication to be successfull. Note: This is one time process only.
```bash
capsule auth login              # Login
```
**Once the user is navigated to login webpage. Please follow the steps below:**
  - Click on "Forgot your password" link
  - In the email address field, enter the emaild id used for requesting the beta access
  - Click on Send Verification Code
  - Enter the verfication code received in the email address
  - Click on Verify code
  - Once verification is completed, click on Continue button
  - Enter your new password and confirm your password
  - Click Continue
  - Password reset is now completed
  - Users will be provided a code, copy the code and paste in the terminal for successfull authentication

**User can now continue with the available commands section on terminal**

## Available Commands

### Authentication
```bash
capsule auth login              # Login
capsule auth logout             # Logout
capsule auth storage            # Authenticate OneDrive access
```

### Machine Management
```bash
capsule list                    # List available machines
capsule list --users            # Show active users
capsule list --json             # JSON output for scripting
```

### Remote Development
```bash
capsule term <config>           # Open Terminal remotely
capsule code <config>           # Open VS Code remotely
capsule cursor <config>         # Open Cursor remotely
```
#### Note: Some launch options (`exec` and `--repo`) are unavailable for Phase 1 of OxCapsule. Please refrain from using these features in this initial release.

### Pixel Streaming (Currently supported for users based in USA only)
```bash
capsule stream <config>         # Launch streaming session
```

### Configuration
```bash
capsule config banner           # Toggle banner display
```

## Getting Help

- **CLI Help**: `capsule --help` or `capsule [command] --help`
- **Discord**: Join our invite-only OxCapsule community. [Discord/OxCapsule](https://discord.gg/Ds5hUdng)
- **Known Issues**: Please refer to github issues on the project here: [OxCapsule/issues](https://github.com/mihira-ai/oxcapsule/issues)
- **Maintanence and Down Time**: Please note that there will be scheduled maintanence which can cause down time. Users are advised to check the discord channel for any updates
- **Support**: OxCapsule support is available Monday–Friday, 9 AM–5 PM PT (US West Coast), please expect delays in responses depending on your time zone.

## [OXMIQ.AI](https://oxmiq.ai/)
