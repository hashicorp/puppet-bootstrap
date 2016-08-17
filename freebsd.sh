#!/usr/bin/env sh

set -e

# This bootstraps Puppet on FreeBSD
echo "Installing Puppet & dependencies..."
if [ `sysctl -n kern.osreldate` -ge '901000' ] && pkg -N 2> /dev/null ; then
	pkg install -y "sysutils/puppet4"
else
	pkg_add -r puppet
fi

echo "Puppet installed!"

