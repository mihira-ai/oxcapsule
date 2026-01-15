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
* OxCapsule connections will currently fail if your network uses a CGNAT, or a symmetric NAT. If you experience issues connecting to machines, please check with your internet service provider whether your network uses CGNAT.
  We are currently looking into potential solutions for this issue.
* Docker is disabled for this update
* Windows updates can fail to remove all files and get stuck in a bad state
* `capsule list` shows blackspace for colored text on macOS