#!/usr/bin/env sh

set -e

# This bootstraps Puppet on FreeBSD
echo "Installing Puppet & dependencies..."
# See manpage of pkg(8)
# https://www.freebsd.org/cgi/man.cgi?query=pkg&apropos=0&sektion=8
if TMPDIR=/dev/null ASSUME_ALWAYS_YES=1 \
    PACKAGESITE=file:///nonexistent \
    pkg info -x 'pkg(-devel)?$' >/dev/null 2>&1; then
	pkg install -y "sysutils/puppet4"
else
	pkg_add -r puppet
fi

echo "Puppet installed!"

