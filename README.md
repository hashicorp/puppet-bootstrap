# Puppet Bootstrap Scripts

## Usage

### One Line Install/Configure/Start Puppet (test)

```shell
\curl -sSL https://git.io/vLD6L | sudo bash
```

### One Line Install/Configure/Start Puppet (production)

```shell
\curl -sSL https://git.io/vLD6L | sudo bash -s '' production
```
### One Line Install/Configure/Start Puppet (from puppet 4 collection)

```shell
\curl -sSL https://git.io/vLD6L | sudo bash -s '' locdev pc1
```

### One Line Install/Configure/Start Puppet (Windows)

```shell
# PowerShell
iex ((New-Object net.webclient).DownloadString('https://git.io/vanax'))
```
```shell
# cmd.exe
@powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object net.webclient).DownloadString('https://git.io/vanax'))"
```

### Install/Configure/Start Puppet (Windows - production)
```shell
# PowerShell
$env:PuppetEnvironment = "production"
iex ((New-Object net.webclient).DownloadString('https://git.io/vanax'))
```

### Advanced Install/Configure/Start Puppet

```shell
curl -L https://github.com/MiamiOH/puppet-bootstrap/archive/master.tar.gz | tar xzv
sudo puppet-bootstrap-master/bootstrap.sh osx
rm -rf puppet-bootstrap-master
```

### bootstrap options

```shell
./bootstrap.sh {redhat_5|redhat_6|redhat_7|debian|ubuntu|osx} [environment] [collection] [server]
```

### force puppet run (after sign cert)

```shell
sudo puppet agent --test
```

### set hostname on OS X (may need this)

```shell
sudo scutil --set LocalHostName <hostname>
sudo scutil --set ComputerName <hostname>
sudo scutil --set HostName <hostname>.miamioh.edu
```

## Overview

This repository contains a multitude of single file scripts for setting
up [Puppet](http://puppetlabs.com/puppet/what-is-puppet/) on a variety
of machines.

Puppet is fantastic for managing infrastructure but there is a chicken/egg problem
of getting Puppet initially installed on a machine so that Puppet can then
take over for the remainder of system setup. This repository contains small scripts
to bootstrap your system just enough so that Puppet can then take over.

**Please contribute by forking and sending a pull request for your
operating system.**

The goal of this repository is to create a set of scripts that run
on every version of every platform to set up Puppet.

## Features of Each Script

* Requires no parameters and runs without any human input, but can
  optionally take parameters to tune the packages the install and such. See
  each script for details on the parameters.
* Uses only _built-in_ software to install Puppet. These scripts
  have no external dependencies over the base install of their OS.
* Installs Puppet agent and Facter.
* Does _not_ auto-start the Puppet agent service on the machine. Your
  bootstrap can choose to do this in addition to these scripts, if you'd
  like.

## Using a Script

To use one of the scripts in this repository, you can either download the
script directly from this repository as part of your machine setup process,
or copy the contents of the script you need to your own location and use that.
The latter is recommended since it then doesn't rely on GitHub uptime and
is generally more secure.

If you do choose to download directly from this repository, make sure
you link to a _specific commit_ (and not `master`), so that the file
contents don't change on you unexpectedly.

## Contributing

Fork and pull request. Simple.
