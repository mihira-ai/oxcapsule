# Capsule CLI Installer for Windows
# Usage: irm https://raw.githubusercontent.com/oxmiq/oxcapsule/main/install.ps1 | iex
#        ./install.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ── Configuration ────────────────────────────────────────────────
$CapsuleVersion = "0.5.53"
$ReleaseRepo = "oxmiq/oxcapsule"
$DownloadUrl = "https://github.com/${ReleaseRepo}/releases/download/v${CapsuleVersion}/capsule-cli-install-${CapsuleVersion}.zip"
$DefaultInstallDir = "C:\Program Files\Capsule-CLI"
$TarPattern = "capsule-cli-${CapsuleVersion}-win-x64.tar.gz"

# ── Helpers ──────────────────────────────────────────────────────
function Write-Info    { param([string]$Message) Write-Host "==> " -ForegroundColor Cyan -NoNewline; Write-Host $Message -ForegroundColor White }
function Write-Success { param([string]$Message) Write-Host "==> " -ForegroundColor Green -NoNewline; Write-Host $Message -ForegroundColor White }
function Write-Warn    { param([string]$Message) Write-Host "Warning: " -ForegroundColor Yellow -NoNewline; Write-Host $Message }
function Exit-WithError {
    param([string]$Message)
    Write-Host "Error: " -ForegroundColor Red -NoNewline
    Write-Host $Message
    exit 1
}

function Read-PromptWithDefault {
    param([string]$Prompt, [string]$Default)
    $response = Read-Host "$Prompt [$Default]"
    if ([string]::IsNullOrWhiteSpace($response)) { return $Default }
    return $response
}

function Read-YesNoPrompt {
    param([string]$Prompt, [string]$Default = "Y")
    $promptText = if ($Default -eq "Y") { "$Prompt [Y/n]" } else { "$Prompt [y/N]" }
    $response = Read-Host $promptText
    if ([string]::IsNullOrWhiteSpace($response)) { $response = $Default }
    return $response -match '^[Yy]$'
}

function Test-Administrator {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Add-ToSystemPath {
    param([string]$PathToAdd)
    $currentPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)
    $pathArray = $currentPath -split ';'
    if ($pathArray -contains $PathToAdd) {
        Write-Warn "Capsule is already in system PATH"
        return
    }
    $newPath = "$currentPath;$PathToAdd"
    [Environment]::SetEnvironmentVariable("Path", $newPath, [EnvironmentVariableTarget]::Machine)
    $env:Path = "$env:Path;$PathToAdd"
    Write-Success "Added Capsule to system PATH"
}

# ── Main ─────────────────────────────────────────────────────────
function Install-Capsule {
    Write-Host ""
    Write-Host "  Capsule CLI Installer v${CapsuleVersion}" -ForegroundColor Green
    Write-Host "  ----------------------------------"
    Write-Host ""

    # Admin check
    if (-not (Test-Administrator)) {
        Write-Warn "This script should be run as Administrator for proper installation."
        if (-not (Read-YesNoPrompt "Continue without Administrator privileges?" "N")) {
            Exit-WithError "Installation cancelled. Please right-click PowerShell and select 'Run as Administrator'."
        }
    }

    # Check for tar command (Windows 10 1803+)
    if (-not (Get-Command tar -ErrorAction SilentlyContinue)) {
        Exit-WithError "The 'tar' command is required (Windows 10 version 1803+). Please update your Windows installation."
    }

    # Download
    $tempDir = Join-Path $env:TEMP "capsule-install-$(Get-Random)"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

    try {
        Write-Info "Downloading Capsule CLI v${CapsuleVersion}..."
        $zipPath = Join-Path $tempDir "capsule-install.zip"
        & curl.exe -fsSL --http1.1 -o $zipPath $DownloadUrl
        if ($LASTEXITCODE -ne 0) {
            Exit-WithError "Failed to download from ${DownloadUrl}"
        }

        Write-Info "Extracting package..."
        try {
            Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force
        }
        catch {
            Exit-WithError "Failed to extract zip archive: $($_.Exception.Message)"
        }

        $tarFile = Get-ChildItem -Path $tempDir -Filter $TarPattern -Recurse | Select-Object -First 1
        if (-not $tarFile) {
            Exit-WithError "Could not find ${TarPattern} in the downloaded package"
        }

        Write-Info "Extracting ${TarPattern}..."
        $extractDir = Join-Path $tempDir "extracted"
        New-Item -ItemType Directory -Path $extractDir -Force | Out-Null
        & tar -xzf $tarFile.FullName -C $extractDir
        if ($LASTEXITCODE -ne 0) {
            Exit-WithError "Failed to extract ${TarPattern}"
        }

        $binPath = Join-Path $extractDir "bin"
        if (-not (Test-Path $binPath)) {
            Exit-WithError "Expected 'bin' directory not found after extraction"
        }

        # Step 1: installation location
        Write-Host ""
        Write-Host "Step 1: Installation location"
        $InstallDir = Read-PromptWithDefault "Installation directory" $DefaultInstallDir

        if (Test-Path $InstallDir) {
            Write-Warn "Installation directory already exists: $InstallDir"
            if (Read-YesNoPrompt "Overwrite existing installation?" "Y") {
                try { Remove-Item -Path $InstallDir -Recurse -Force }
                catch { Exit-WithError "Failed to remove existing installation: $($_.Exception.Message)" }
            }
            else {
                Exit-WithError "Installation cancelled."
            }
        }

        # Step 2: install files
        Write-Host ""
        Write-Host "Step 2: Installing files to $InstallDir..."
        New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
        Copy-Item -Path $binPath -Destination $InstallDir -Recurse -Force

        $exePath = Join-Path $InstallDir "bin\capsule.exe"
        if (-not (Test-Path $exePath)) {
            Exit-WithError "capsule.exe not found after installation"
        }

        Write-Info "Unblocking executable files..."
        Get-ChildItem -Path $InstallDir -Recurse -Include "*.exe","*.dll" | ForEach-Object {
            Unblock-File -Path $_.FullName
        }

        # Step 3: PATH configuration
        Write-Host ""
        Write-Host "Step 3: PATH configuration"
        $capsuleBinPath = Join-Path $InstallDir "bin"
        if (Read-YesNoPrompt "Add Capsule to system PATH?" "Y") {
            Add-ToSystemPath -PathToAdd $capsuleBinPath
        }
        else {
            Write-Warn "Skipping PATH update"
        }

        # Step 4: rclone dependency
        Write-Host ""
        Write-Host "Step 4: Dependencies"
        if (-not (Get-Command rclone -ErrorAction SilentlyContinue)) {
            if (Read-YesNoPrompt "Install rclone (required for storage features)?" "Y") {
                $wingetCmd = Get-Command winget -ErrorAction SilentlyContinue
                if ($wingetCmd) {
                    Write-Info "Installing rclone..."
                    & winget install Rclone.Rclone --accept-package-agreements --accept-source-agreements 2>&1 | Out-Null
                    if ($LASTEXITCODE -eq 0) {
                        Write-Success "rclone installed"
                    }
                    else {
                        Write-Warn "Could not install rclone automatically. Please install it manually: https://rclone.org/install/"
                    }
                }
                else {
                    Write-Warn "winget is not available. Please install rclone manually: https://rclone.org/install/"
                }
            }
            else {
                Write-Warn "Skipping rclone installation"
            }
        }

        # Summary
        Write-Host ""
        Write-Success "Installation completed successfully!"
        Write-Host ""
        Write-Host "  Installation summary:"
        Write-Host "    Installed to: $InstallDir"
        Write-Host "    Executable:   $InstallDir\bin\capsule.exe"
        Write-Host ""

        # Verify
        Write-Host "  Verifying installation..."
        $capsuleInPath = Get-Command capsule -ErrorAction SilentlyContinue
        if ($capsuleInPath) {
            Write-Success "capsule command is available in your PATH"
        }
        elseif (Test-Path $exePath) {
            Write-Success "Capsule executable found at $exePath"
            Write-Warn "Open a new terminal for the 'capsule' command to be available."
        }
        else {
            Write-Warn "Could not verify installation. Check $exePath"
        }

        Write-Host ""
        Write-Host "  Get started:"
        Write-Host "    capsule auth login      " -NoNewline; Write-Host "Log in to your account" -ForegroundColor Gray
        Write-Host "    capsule list            " -NoNewline; Write-Host "List available servers" -ForegroundColor Gray
        Write-Host "    capsule --help          " -NoNewline; Write-Host "Show all commands" -ForegroundColor Gray
        Write-Host ""
        Write-Host "  NOTE: Open a new terminal window for PATH changes to take effect." -ForegroundColor Yellow
        Write-Host ""
    }
    finally {
        if (Test-Path $tempDir) {
            Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

try {
    Install-Capsule
}
catch {
    Exit-WithError "Unexpected error: $($_.Exception.Message)"
}
