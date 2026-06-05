## Troubleshooting

### Common Usage Issues

1. **Authentication Failures**
   - Ensure you're logged in: `capsule auth login`
   - Check network connectivity
   - Verify your credentials are valid

2. **Configuration Tag Not Found**
   - Run `capsule list` to see available configuration tags

3. **Connection Issues**
   - Verify network connectivity to remote servers
   - Check your internet firewall settings
   - If on Linux, please download the following packages:
   ```
      sudo apt install libgl1 libglu1 libxdamage1 libva2 libva-drm2 libva-x11-2 libvdpau1
   ```

4. **MacOS prompt to "Allow Keychain Access"**
   - Your authentication token needs to be stored securely in Apple's vault.
   - Enter your system password and click "Always Allow" to allow OxCapsule to safely store credentials on your system. This prompt will reappear after every capsule update.

5. **Mounting a Personal OneDrive**
   - Open a docker container on remote machine
   - Run this command to setup docker: `docker run -v ~/OneDrive:/OneDrive -it ubuntu`

6. **In a mount, git shows all files as executable**
   - Mounts will automatically set every file and folder to executable. This cannot be disabled. If this setting interferes with git versioning, the setting `git config core.fileMode false` must be run to ignore this change. 

### Log Files

For additional debugging, check the log files located at:

- **Windows**: `%APPDATA%\capsule\logs`
- **macOS**: `~/Library/Application Support/capsule/logs`
- **Linux** `$HOME/.config/capsule/logs/`
