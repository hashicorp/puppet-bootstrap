<#
.SYNOPSIS
    Installs Puppet on this machine.

.DESCRIPTION
    Downloads and installs the PuppetLabs Puppet MSI package.

    This script requires administrative privileges.

    You can run this script from an old-style cmd.exe prompt using the
    following:

      powershell.exe -ExecutionPolicy Unrestricted -NoLogo -NoProfile -Command "& '.\windows.ps1'"

.PARAMETER MsiUrl
    This is the URL to the Puppet MSI file you want to install. This defaults
    to a version from PuppetLabs.

.PARAMETER PuppetVersion
    This is the version of Puppet that you want to install. If you pass this it will override the version in the MsiUrl.
    This defaults to $null.

.PARAMETER PuppetCertname
    The certname to use for this puppet agent.
    This defaults to $env:computername.

.PARAMETER PuppetEnvironment
    The environment to use for this puppet agent.
    This defaults to "test".
#>
param(
   [string]$MsiUrl = "https://downloads.puppetlabs.com/windows/puppet-x64-latest.msi"
  ,[string]$PuppetVersion = "null"
  ,[string]$PuppetCertname = $env:computername
  ,[string]$PuppetEnvironment = $env:PuppetEnvironment
)

if ($PuppetVersion -ne "null") {
  $MsiUrl = "https://downloads.puppetlabs.com/windows/puppet-$($PuppetVersion).msi"
  Write-Host "Puppet version $PuppetVersion specified, updated MsiUrl to `"$MsiUrl`""
}

if (!($PuppetEnvironment)) { $PuppetEnvironment = "test" }
switch ($PuppetEnvironment) {
  locdev      { $PuppetServer = "localhost" }
  vagrant     { $PuppetServer = "localhost" }
  esodev      { $PuppetServer = "uitlpupt02.mcs.miamioh.edu" }
  esotst      { $PuppetServer = "uitlpupt02.mcs.miamioh.edu" }
  development { $PuppetServer = "uitlpupp02.mcs.miamioh.edu" }
  test        { $PuppetServer = "uitlpupp02.mcs.miamioh.edu" }
  staging     { $PuppetServer = "uitlpupp02.mcs.miamioh.edu" }
  production  { $PuppetServer = "uitlpupp02.mcs.miamioh.edu" }
  default     {
    Write-Error "Unknown/Unsupported PuppetEnvironment."
    Exit 1
  }
}

switch ($PuppetEnvironment) {
  locdev  { $PuppetCmd = "`"C:\Program Files\Puppet Labs\Puppet\bin\puppet`" apply --config C:\ProgramData\PuppetLabs\puppet\etc\puppet.conf C:\ProgramData\PuppetLabs\puppet\etc\manifests" }
  default { $PuppetCmd = "`"C:\Program Files\Puppet Labs\Puppet\bin\puppet`" agent --config C:\ProgramData\PuppetLabs\puppet\etc\puppet.conf --onetime --no-daemonize" }
}

$PuppetInstalled = $false
try {
  $ErrorActionPreference = "Stop";
  Get-Command puppet | Out-Null
  $PuppetInstalled = $true
  $PuppetVersion=&puppet "--version"
  Write-Host "Puppet $PuppetVersion is installed. This process does not ensure the exact version or at least version specified, but only that puppet is installed. Exiting..."
  Exit 0
} catch {
  Write-Host "Puppet is not installed, continuing..."
}

if (!($PuppetInstalled)) {
  $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
  if (! ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {
    Write-Error "You must run this script as an administrator."
    Exit 1
  }

  # Install chocolatey
  Write-Host "Installing Chocolatey"
  iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))

  # Install it - use chocolatey
  $install_args = @("install", "puppet", "-y")
  Write-Host "Installing Puppet. Running choco.exe $install_args"
  $process = Start-Process -FilePath choco.exe -ArgumentList $install_args -Wait -PassThru
  if ($process.ExitCode -ne 0) {
    Write-Error "Installer failed."
    Exit 1
  }

  # Stop the service that it autostarts
  Write-Host "Stopping Puppet service that is running by default..."
  Start-Sleep -s 5
  Set-Service -Name puppet -StartupType Disabled -Status Stopped

  Write-Host "Puppet successfully installed."

  if ($PuppetEnvironment -ne "vagrant") {
    Write-Host "Configuring Puppet..."
@"
### File placed by puppet-bootstrap ###
## https://docs.puppetlabs.com/references/3.stable/configuration.html
#

[main]
    vardir = C:\ProgramData\PuppetLabs\puppet\var\lib
    logdir = C:\ProgramData\PuppetLabs\puppet\var\log
    rundir = C:\ProgramData\PuppetLabs\puppet\var\run
    ssldir = `$vardir/ssl

[agent]
    pluginsync      = true
    report          = true
    ignoreschedules = true
    daemon          = false
    ca_server       = $PuppetServer
    certname        = $PuppetCertname
    environment     = $PuppetEnvironment
    server          = $PuppetServer
    stringify_facts = false

[user]
    environment     = $PuppetEnvironment
    parser          = future
    stringify_facts = false
    ordering        = manifest
"@ | Out-File C:\ProgramData\PuppetLabs\puppet\etc\puppet.conf -encoding ASCII

    Write-Host "Starting Puppet ScheduledTask..."
    $action = New-ScheduledTaskAction -Execute $PuppetCmd
    $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionDuration ([timeSpan]::maxvalue) -RepetitionInterval (New-TimeSpan -Hours 1)
    Register-ScheduledTask -TaskName "puppet" -Action $action -Trigger $trigger -User "Administrator"
  }

  Write-Host "Success!!"
}
