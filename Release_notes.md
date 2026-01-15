# Releases

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
