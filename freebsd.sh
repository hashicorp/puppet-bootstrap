#!/usr/bin/env sh

set -e

# This bootstraps Puppet on FreeBSD

if [ `sysctl -n kern.osreldate` -ge '901000' ] && pkg -N 2> /dev/null ; then
  have_pkg=true;
else
  have_pkg=false;
fi

echo "Installing Puppet & dependencies..."
if $have_pkg; then
	export ASSUME_ALWAYS_YES=yes
	pkg install "sysutils/puppet4"
	unset ASSUME_ALWAYS_YES
else
	pkg_add -r puppet
fi

echo "Puppet installed!"

