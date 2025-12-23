# Reset-UbuntuWSL.ps1
# Run this script in PowerShell as Administrator

Write-Host "=== Resetting Ubuntu WSL ===" -ForegroundColor Cyan

# Step 1: Unregister existing Ubuntu distro (if present)
Write-Host "Unregistering existing Ubuntu distro..."
wsl --unregister Ubuntu 2>$null

# Step 2: Remove leftover package folders (if any)
# Find all Canonical Ubuntu package folders dynamically
$ubuntuPkgs = Get-ChildItem "C:\Users\$env:USERNAME\AppData\Local\Packages" -Directory |
              Where-Object { $_.Name -like "CanonicalGroupLimited*" }

foreach ($pkg in $ubuntuPkgs) {
    Write-Host "Cleaning leftover Ubuntu package folder: $($pkg.FullName)"
    try {
        Remove-Item -Recurse -Force $pkg.FullName
    } catch {
        Write-Host "Some locked files in $($pkg.FullName) could not be removed. A reboot may clear them." -ForegroundColor Yellow
    }
}

# Step 3: Ensure WSL feature is enabled
Write-Host "Enabling WSL and Virtual Machine Platform features..."
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Step 4: Install Ubuntu fresh
Write-Host "Installing Ubuntu from WSL..."
wsl --install -d Ubuntu

Write-Host "=== Ubuntu WSL reset complete ===" -ForegroundColor Green
Write-Host "Launch Ubuntu from Start Menu or run 'wsl -d Ubuntu' to finish setup."