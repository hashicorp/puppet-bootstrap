# Puppet Bootstrap Scripts

This repository contains a multitude of single file scripts for setting
up [Puppet](http://puppetlabs.com/puppet/what-is-puppet/) on a variety
of machines. Puppet is fantastic for managing infrastructure but there is a
chicken/egg problem of getting Puppet on a machine so that Puppet can then manage
the installation and configuration of software on the machine. This repository
contains small scripts to bootstrap your Puppet setup on various operating
systems.

**Please contribute by forking and sending a pull request for your
operating system.**

The goal of this repository is to create a set of scripts that run
on every version of every platform to set up Puppet.

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
