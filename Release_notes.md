# Releases

## v0.2.83 - release Feb 18 2025

Our latest OxCapsule version adds several new functionalities focusing on enhancing storage solutions and data transfer.

To download the latest version, please try running "`capsule update`" to get the newest capsule version. 
What's New:

## 🤖 Capsule Benchmark

- New `capsule benchmark` command: `capsule benchmark -u <machine-name> <model-name>`
- One-command LLM inference benchmarking on remote GPU machines
- Automatic GPU detection, backend selection, and optimization
- Comprehensive metrics: throughput (requests/sec, tokens/sec), TTFT, TPOT, ITL
- Supported NVIDIA GPUs: **RTX 5090, RTX A6000**
- Supported AMD/Intel GPUs: **AMD Radeon RX 7900 XTX, Intel Arc A770/B60**

## 📩 Scp Command
- New `capsule scp` command to allow copying of files between your local machine and other capsule machines.
- `capsule scp upload` to send files/folders to the remote machine
- `capsule scp download` to retrieve files/folders from a remote machine

## 💡Capsule CLI Improvements

- Docker access returned to the public environment
- Capsule tests show up on the tests Dashboard
- Fixed issue with`capsule list` for MacOS where terminals showed blackspace errors.
- Fixed warnings and crashes with `capsule stream` on MacOS
- Increased idle-timeout to 90 minutes.
- Fixed bug where machines fail to come back after a system reboot.
- Additional client logging for connections
- Significantly reduced server log spam
- Various improvements to automation and packaging
- Fixed issue where OneDrive mount would expire and fail to remount
- Package-dependent default environment
- VRAM Capacity displays for Windows machines

## 📦 Local Persistent Storage
- UserStorage directory available for use as persistent storage across machines.
- Take your data across multiple machines where it's stored between sessions

## ✅ Bashrc Override
- OxCapsule automatically preserves any edits you make to your .bashrc file
- `capsule config bashrc_override enable/disable` commands
- Enable bashrc override to override your .bashrc file on launch

## 🚀 New Launch Options
- `--options` is available when using the `ssh`, `term`, or `scp` commands, allows the passing in of ssh options.

## v0.2.48 - release Jan 14 2025

### What's New:

#### 🌐 Improved Connection Handling
* More stable connections, with smarter reconnect and timeout logic.
* Reduces frequency and severity of hanging sessions
* Client and server-side OxCapsule processes auto clean themselves.
* Significantly reduces situations requiring `capsule cleanup`
#### 🔍 Exec Command
* Use this command to run a command on an OxCapsule machine.
#### 🚀 Capsule CLI Improvements
* Various security improvements to the infrastructure of OxCapsule
* Clearer instructions on how to find logs
* `cap` fully available as a shortcut for `capsule`
* Improvements to GPU info provided by `capsule list`
* `capsule auth login` command times out when provided no input.
#### 🖥️ User Telemetry - Metrics on active users and sessions
* OxCapsule now track active users, sessions, and machines
* Allows for more powerful session management

#### 🚨 Known Limitations and Issues
* Docker is disabled for this update
* Windows updates can fail to remove all files and get stuck in a bad state
* `capsule list` shows blackspace for colored text on macOS

## v 0.2.29 - release Dec 4 2025

### What's New:

#### 🔄 capsule update
* `capsule update` command added, to install any future updates to OxCapsule
* Run `capsule update --check-only` to determine whether there is a new update available

#### 🖥️ Linux login support – For systems without a browser
* You can now run OxCapsule on Linux devices. Launching is limited to the `term` and `ssh` commands.
* Login now supports fallback logic on all versions
* Download the package here: __OxCapsule_Client__

#### ⏱️ Configurable idle timeout
* Terminal-based launch commands (e.g. term, code, launch) support an idle-timeout flag for the amount of time before disconnecting from your machine.
* Set using `--idle-timeout <timeout-limit>` with a time limit (e.g. 30s, 5m, 2h, 1d)

#### 🔍 capsule list enhancements
* Displays count per machine type
* Better grouping for various GPUs 

#### 🚀 OxCapsule Fixes
* Fixed issue where small terminal width causes the banner and `capsule list` output to fail
* Fixed issue where commands would execute even if the `—help` flag was included
* `capsule ssh` made again to serve as an alias for `capsule term`
* Reconnection logic to machines made more consistent
* Added logging for various scenarios

#### 🚨 Known Issues
* OxCapsule connections will currently fail if your network uses a CGNAT, or a symmetric NAT. If you experience issues connecting to machines, please check with your internet service provider whether your network uses CGNAT.
