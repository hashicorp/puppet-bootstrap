# This script installs Puppet on a Windows machine.

$downloadUrl = "http://puppetlabs.com/downloads/windows/puppet-3.0.1.msi"

#--------------------------------------------------------------------
# NO TUNABLE BELOW THIS POINT
#--------------------------------------------------------------------
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host -ForegroundColor Red "You must run this script as an administrator."
    Exit 1
}

# Download Puppet
Write-Host "Downloading Puppet..."
$downloadPath = [IO.Path]::GetTempFileName()
$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile($downloadUrl, $downloadPath)

# Install it
Write-Host "Installing Puppet..."
$install_args = @("/i", $downloadPath, "/qn", "/norestart")
$process = Start-Process -FilePath msiexec.exe -ArgumentList $install_args -Wait -PassThru
if ($process.ExitCode -ne 0) {
    Write-Host "Installer failed."
    Exit 1
}

# Stop the service that it autostarts
Write-Host "Stopping Puppet service that is running by default..."
Stop-Service -Name puppet

Write-Host "Puppet successfully installed."
