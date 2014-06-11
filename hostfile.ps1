<#
  .DESCRIPTION
    This function checks to see if an entry exists in the hosts file.
    If it does not, it attempts to add it and verifies the entry.

  .EXAMPLE
    hostfile -IPAddress 192.168.0.1 -HostName MyMachine

  .EXTERNALHELP
    None.

  .FORWARDHELPTARGETNAME
    None.

  .INPUTS
    System.String.

  .LINK
    None.

  .NOTES
    None.

  .OUTPUTS
    System.String.

  .PARAMETER IPAddress
    A string representing an IP address.

  .PARAMETER HostName
    A string representing a host name.

  .SYNOPSIS
    Add entries to the hosts file.
#>

param(
  [parameter(Mandatory=$true,position=0)]
[string]
$IPAddress,
[parameter(Mandatory=$true,position=1)]
[string]
$HostName
)

$HostsLocation = "$env:windir\System32\drivers\etc\hosts";
$NewHostEntry = "`t$IPAddress`t$HostName";

if((gc $HostsLocation) -contains $NewHostEntry)
{
  Write-Host "The hosts file $HostsLocation already contains the following entry:";
  Write-Host "$NewHostEntry"
}
else
{
  Write-Host "Updating $HostsLocation file with:"
  Write-Host "$NewHostEntry"
  Add-Content -Path $HostsLocation -Value $NewHostEntry;
}