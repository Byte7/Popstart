# WSL2 and Ubuntu 24.04 LTS Setup Script
# This script automates the setup of WSL2 features and installs Ubuntu 24.04 LTS

# Function to log messages
function Log-Message {
    param (
        [string]$Message,
        [string]$LogLevel = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp [$LogLevel] $Message"
    Write-Host $logEntry
    Add-Content -Path "wsl_setup.log" -Value $logEntry
}

# Function to check if running as administrator
function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Function to check if a Windows feature is enabled
function Is-WindowsFeatureEnabled {
    param (
        [string]$FeatureName
    )
    $feature = Get-WindowsOptionalFeature -Online -FeatureName $FeatureName
    return $feature.State -eq "Enabled"
}

# Check if running as administrator
if (-not (Test-Admin)) {
    Log-Message "This script requires administrator privileges. Please run as administrator." "ERROR"
    exit 1
}

# Enable Windows features if not already enabled
$wslfEnabled = Is-WindowsFeatureEnabled "Microsoft-Windows-Subsystem-Linux"
$vmpEnabled = Is-WindowsFeatureEnabled "VirtualMachinePlatform"

if (-not $wslfEnabled) {
    try {
        Log-Message "Enabling Windows Subsystem for Linux feature..."
        dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
        Log-Message "Windows Subsystem for Linux feature enabled successfully."
    } catch {
        Log-Message "Error enabling Windows Subsystem for Linux feature: $_" "ERROR"
        exit 1
    }
} else {
    Log-Message "Windows Subsystem for Linux feature is already enabled."
}

if (-not $vmpEnabled) {
    try {
        Log-Message "Enabling Virtual Machine Platform feature..."
        dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
        Log-Message "Virtual Machine Platform feature enabled successfully."
    } catch {
        Log-Message "Error enabling Virtual Machine Platform feature: $_" "ERROR"
        exit 1
    }
} else {
    Log-Message "Virtual Machine Platform feature is already enabled."
}

# Set WSL2 as the default version
try {
    Log-Message "Setting WSL2 as the default version..."
    wsl --set-default-version 2
} catch {
    Log-Message "Error setting WSL2 as default: $_" "ERROR"
    exit 1
}

# Install Ubuntu 24.04 LTS
try {
    Log-Message "Installing Ubuntu 24.04 LTS..."
    wsl --install -d Ubuntu-24.04
} catch {
    Log-Message "Error installing Ubuntu 24.04 LTS: $_" "ERROR"
    exit 1
}

Log-Message "WSL2 and Ubuntu 24.04 LTS setup completed successfully."
Log-Message "A system restart is recommended to ensure all changes take effect."

# Prompt user to restart computer
$restart = Read-Host "Do you want to restart now to complete the setup? (Y/N)"
if ($restart -eq "Y" -or $restart -eq "y") {
    Log-Message "Restarting computer..."
    Restart-Computer -Force
} else {
    Log-Message "Please restart your computer at your earliest convenience to complete the setup."
    Log-Message "After restarting, run 'wsl' in a new terminal to complete the Ubuntu setup."
}