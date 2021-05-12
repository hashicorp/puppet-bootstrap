<#
.SYNOPSIS
    Installs Puppet on this machine.

.DESCRIPTION
    Downloads and installs the PuppetLabs Puppet MSI package.

    This script requires administrative privileges.

    You can run this script from an old-style cmd.exe prompt using the
    following:

      powershell.exe -ExecutionPolicy Unrestricted -NoLogo -NoProfile -Command "& '.\windows.ps1'"

.PARAMETER PuppetPackage
    This is the Chocolatey Package you want to install.
    This defaults to puppet (puppet 3.x).

.PARAMETER PuppetCollection
    This is the Collection of Puppet that you want to install. If you pass this it will override the PuppetPackage.
    This defaults to $null.

.PARAMETER PuppetVersion
    This is the Version of Puppet that you want to install. puppet-agent jumps major versions in Chocolatey.
    This defaults to $null.

.PARAMETER PuppetCertname
    The certname to use for this puppet agent.
    This defaults to $env:computername.

.PARAMETER PuppetEnvironment
    The environment to use for this puppet agent.
    This defaults to "test".

.PARAMETER PuppetServer
    The Puppet Server to use for this puppet agent.
    This defaults to a guess based on PuppetEnvironment.

.PARAMETER PuppetCAServer
    The Puppet CA Server to use for this puppet agent.
    This defaults to a guess based on PuppetEnvironment.

.PARAMETER chocolateyProxyLocation
    Use this web proxy to do the install.

.PARAMETER PuppetScheduledTask
    Set to undef to skip setting up the ScheduledTask.
#>
param(
  [string]$PuppetPackage = "puppet"
  , [string]$PuppetCollection = $env:PuppetCollection
  , [string]$PuppetVersion = $env:PuppetVersion
  , [string]$PuppetCertname = $env:PuppetCertname
  , [string]$PuppetEnvironment = $env:PuppetEnvironment
  , [string]$PuppetServer = $env:PuppetServer
  , [string]$PuppetCAServer = $env:PuppetCAServer
  , [string]$chocolateyProxyLocation = $env:chocolateyProxyLocation
  , [string]$PuppetScheduledTask = $env:PuppetScheduledTask
)

if ($PuppetCollection) {
  $PuppetPackage = "puppet-agent"
  Write-Host "Puppet Collection $PuppetCollection specified, updated PuppetPackage to `"$PuppetPackage`""
  $PuppetApplyManifests = "C:\ProgramData\PuppetLabs\code\environments\$PuppetEnvironment\manifests"
}
else {
  $PuppetApplyManifests = "C:\ProgramData\PuppetLabs\puppet\etc\manifests"
}

if (!($PuppetEnvironment)) { $PuppetEnvironment = "test" }
if (!($PuppetCertname)) {
  # Try and query the system
  $sysinfo = Get-WmiObject -Class Win32_ComputerSystem
  if ($sysinfo.Name) {
    if ($sysinfo.Domain) {
      $PuppetCertname = ($sysinfo.Name + "." + $sysinfo.Domain).tolower()
    }
    else {
      switch -regex ($PuppetEnvironment) {
        'locprd|production' { $PuppetCertname = ($sysinfo.Name + ".it.muohio.edu").tolower() }
        default { $PuppetCertname = ($sysinfo.Name + ".ittst.muohio.edu").tolower() }
      }
    }
  }
  else {
    Write-Error "Can not auto determine PuppetCertname."
    Exit 1
  }
}

if (!($PuppetServer)) {
  switch -regex ($PuppetEnvironment) {
    'locdev|loctst|locprd|vagrant|all' { $PuppetServer = "localhost" }
    'esodev|esotst' { $PuppetServer = "uitlpupt10.mcs.miamioh.edu" }
    'development|test|staging|production|operations|shared_services' { $PuppetServer = "uitlpupp10.mcs.miamioh.edu" }
    default {
      Write-Error "Unknown/Unsupported PuppetEnvironment."
      Exit 1
    }
  }
}
if (!($PuppetCAServer)) { $PuppetCAServer = $PuppetServer }

$PuppetCmd = "C:\Program Files\Puppet Labs\Puppet\bin\puppet.bat"
switch -regex ($PuppetEnvironment) {
  'locdev|loctst|locprd|vagrant|all' { $PuppetArg = "apply --config C:\ProgramData\PuppetLabs\puppet\etc\puppet.conf $PuppetApplyManifests" }
  default { $PuppetArg = "agent --config C:\ProgramData\PuppetLabs\puppet\etc\puppet.conf --onetime --no-daemonize" }
}

$PuppetInstalled = $false
try {
  $ErrorActionPreference = "Stop";
  Get-Command choco | Out-Null
  $ChocoList = &choco list --limit-output --local-only --exact $PuppetPackage
  if ($ChocoList) {
    Get-Command puppet | Out-Null
    $PuppetInstalled = $true
    $PuppetVersion = &puppet "--version"
    Write-Host "Puppet $PuppetVersion is installed. This process does not ensure the exact version or at least version specified, but only that puppet is installed. Exiting..."
    Exit 0
  }
  else {
    Write-Host "Puppet is not installed, continuing..."
  }
}
catch {
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
  $WebClient = New-Object System.Net.WebClient
  if ($chocolateyProxyLocation) {
    $WebProxy = New-Object System.Net.WebProxy($chocolateyProxyLocation, $true)
    $WebClient.Proxy = $WebProxy
    iex ($WebClient.DownloadString('https://chocolatey.org/install.ps1'))
    choco config set proxy $chocolateyProxyLocation
  }
  else {
    iex ($WebClient.DownloadString('https://chocolatey.org/install.ps1'))
  }

  # Install it - use chocolatey
  $install_args = @("install", $PuppetPackage, "-y")
  if ($PuppetVersion) {
    $install_args += "--version"
    $install_args += $PuppetVersion
  }
  Write-Host "Installing Puppet. Running choco.exe $install_args"
  $process = Start-Process -FilePath choco.exe -ArgumentList $install_args -Wait -PassThru
  if ($process.ExitCode -ne 0) {
    Write-Error "Installer failed."
    Exit 1
  }

  # Stop the service that it autostarts
  Write-Host "Stopping Puppet service that is running by default..."
  Start-Sleep -s 5
  if ($PuppetCollection) {
    New-Item -path "C:\ProgramData\PuppetLabs\code\environments\$PuppetEnvironment" -type directory -force
    try {
      Set-Service -Name mcollective -StartupType Disabled -Status Stopped
    }
    catch {
      Write-Host "Service mcollective not installed"
    }
    Set-Service -Name pxp-agent -StartupType Disabled -Status Stopped
  }
  Set-Service -Name puppet -StartupType Disabled -Status Stopped

  Write-Host "Puppet successfully installed."

  if ($PuppetEnvironment -ne "vagrant") {
    $dir_prefix = 'C:/ProgramData/PuppetLabs/puppet'
    $var_dir = "${dir_prefix}/var"
    $log_dir = "${dir_prefix}/var/log"
    $run_dir = "${dir_prefix}/var/run"
    $ssl_dir = "${dir_prefix}/etc/ssl"
    if ($PuppetCollection) {
      $extra_a_options = ''
      $extra_u_options = ''
    }
    else {
      $extra_a_options = '
    stringify_facts = false'
      $extra_u_options = '
    parser          = future
    stringify_facts = false
    ordering        = manifest'
    }

    Write-Host "Configuring Puppet..."
    @"
### File placed by puppet-bootstrap ###
## https://docs.puppet.com/puppet/latest/reference/configuration.html
#

[main]
    vardir = $var_dir
    logdir = $log_dir
    rundir = $run_dir
    ssldir = $ssl_dir

[agent]
    pluginsync      = true
    report          = true
    ignoreschedules = true
    daemon          = false
    ca_server       = $PuppetCAServer
    certname        = $PuppetCertname
    environment     = $PuppetEnvironment
    server          = $PuppetServer$extra_a_options

[user]
    environment     = $PuppetEnvironment$extra_u_options
"@ | Out-File C:\ProgramData\PuppetLabs\puppet\etc\puppet.conf -encoding ASCII

    if ($PuppetScheduledTask -eq "undef") {
      Write-Host "NOT Starting Puppet ScheduledTask..."
    }
    else {
      Write-Host "Starting Puppet ScheduledTask..."
      schtasks /create /tn "puppet" /tr "'$PuppetCmd' $PuppetArg" /sc DAILY /st 12:00 /ri 60 /du 24:00 /ru SYSTEM /rl HIGHEST /f
    }
  }

  Write-Host "Success!!"
}
