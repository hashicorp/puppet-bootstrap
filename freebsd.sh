#!/usr/bin/env sh

# This bootstraps Puppet on FreeBSD

have_pkg=`grep -sc '^WITH_PKGNG' /etc/make.conf`

echo "Installing Puppet & dependencies..."
if [ "$have_pkg" = 1 ]
then
	export ASSUME_ALWAYS_YES=yes
	pkg install sysutils/puppet
	unset ASSUME_ALWAYS_YES
else
	pkg_add -r puppet
fi

echo "Puppet installed!"

