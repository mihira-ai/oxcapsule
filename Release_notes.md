# Releases

# OxCapsule v0.3.156

Our latest OxCapsule version introduces the new `capsule claude` and `capsule comfy` commands, as well as a variety of QOL improvements for consistency while using capsule. To download the latest version, please try running "capsule update" to get the newest capsule version.

***Warning***: For headless Linux users, authentication will require an unlocked keyring service to be available on your machine. If you do not have a working keyring, use the script "[capsule-keyring-setup.sh](./capsule-keyring-setup.sh)" to setup your user.

What's New:

## 🦀 Capsule Claude
- New `capsule claude` command to connect remote machines to local Claude Code Desktop
- Specify machine name to start a terminal session with that machine in the app

## 🛏️ Capsule Comfy 
- New `capsule comfy` command for port-forwarding ComfyUI via docker container to local machine using remote machines' GPU
- Download gated models by providing HuggingFace token with --hf-token flag
- Choose not default port with --port and docker image with --image
- Has sample video and Kimodo workflows to run

## 📅 Capsule Session
- New `capsule session command` for dealing with all current capsule sessions
- `capsule session list` to list all current connections
- `capsule end` and `endall` to kill specific or all connections

## 💡 Capsule CLI Improvements
- Linux authentication lasts much longer
- Packages for Arm64 Linux client support
- Added VRAM retrieval for Apple Silicon machines
- `config`: Standardized options
- `schedule`: Added --atributes flag for resource-aware dispatch
- `benchmark`: Allow multi-segment model identifiers
- Added modelhosting configurations

# OxCapsule v0.3.127

Our latest OxCapsule version introduces app streaming, the new `capsule schedule` and `capsule chat` commands, and a variety of quality of life improvements across the CLI and streamer. The `capsule launch` command has been deprecated in favor of `capsule terminal`. Make sure to run `capsule update` to get the newest version.

What's New:

## 🎮 App Streaming
- Stream specific applications instead of full desktops with `capsule stream --app <app-id>`
- Configuration file support for advanced streaming setups
- Only available for streaming from and to Windows machines
- Available apps are `davinci_resolve` and `blender`

## 📅 Capsule Schedule Command
- New `capsule schedule` command for running tasks on remote machines using scripts
- Can run multiple tasks concurrently
- Use `capsule schedule status` and `capsule schedule logs [task-id]` to view statuses of running tasks
- E.g. `capsule schedule start --machine-name Machine --script hello_world.sh --name "Hello World"`

## 🗨️ Capsule Chat Command
- New `capsule chat` command for conversing with models using remote machines' GPUs
- E.g. `capsule chat -u Machine Qwen/Qwen2-0.5B-Instruct`
- Use `.exit` to leave the chat

## 🤖 Capsule MCP Command
- New `capsule mcp` command for adding an mcp plugin to your agents and AI tools
- Allows agents to list machines, launch benchmarks, and run commands

## 🖥️ Capsule Status Command
- New `capsule status` command for viewing current session and connection info

## 📊 Benchmark Improvements
- Added `--idle-timeout` and `--max-session-length` arguments to `capsule benchmark`
- Disk space pre-flight check before benchmark runs

## 🖼️ `capsule stream` Improvements
- Fixed issues with `capsule stream` failing to startup and displaying black screens
- Improved `capsule stream` performance
- Improved mouse tracking in resized windows

## 💡 Capsule CLI Improvements
- `capsule launch` deprecated, and now an alias of `capsule ssh`
- Expired tokens now explicitly rejected during `auth login`
- Private capsule machines now show in `capsule list`
- Hide updater logs on macOS
- Added appropriate fallbacks for launching with `--repo`
- Added `user-storage-mount-dir` config option
- Fixes to prevent hanging sessions and reconnect attempts

## 🐚 Session Setup
- Welcome message displayed on session connect

# OxCapsule v0.3.13 - release Mar 18 2026

Our latest OxCapsule version is focused on quality of life improvements for connectivity and preventing connection dropouts. In addition, Ubuntu 22.04 compatibility was reintroduced for Linux clients. Make sure download this latest client to leverage the variety of connection fixes made by the OxCapsule team.

To download the latest version, please try running "`capsule update`" to get the newest capsule version. 
What's New:

## 🤖 Capsule Benchmark
- Website for viewing benchmark results: https://oxcapsulebenchmark.z22.web.core.windows.net/
- GPU support: RTX 5090, RTX A6000, AMD TinyBox
- Run benchmarks using either --backend vllm or --backend llamacpp
- Run capsule benchmark --help to see all available parameters

##  🔌 Connection Fixes
- Fixed issue where all connections would drop after any individual connection drops
- Fixed various bugs involving connection state tracking
- Fixed issue on Windows where connections wouldn't close ports

## 🖥️ Linux Ubuntu 22.04
- Reintroduced support for Linux Ubuntu 22.04 as a separate package

## 💡Capsule CLI Improvements
- `capsule list --filter` can filter by OS
- Log messages made more unified across commands
- Better handling of `capsule update` timeout 
- `capsule update` on Linux will download apt dependencies
- Better UI for `capsule update`

## 📦 Storage Changes
- Flexible storage quota design to control available storage

## v0.2.83 - release Feb 18 2026

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

## v0.2.48 - release Jan 14 2026

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

## v0.2.29 - release Dec 4 2025

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
