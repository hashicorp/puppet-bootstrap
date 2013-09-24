#!/usr/bin/env bash
#
# This bootstraps Puppet on Solaris 10/11.
#
set -e

if [ "$(/usr/xpg4/bin/id -u)" != "0" ]; then
	echo "This script must be run as root." >&2
	exit 1
fi

# Install pkgutil if not present
if [ ! -f /opt/csw/bin/pkgutil ]; then
	echo "Installing pkgutil..."
	# Create the admin file
	tee /tmp/pkgutil-admin <<-EOF >/dev/null
	action=nocheck
	conflict=nocheck
	idepend=nocheck
	instance=overwrite
	mail=
	partial=nocheck
	runlevel=nocheck
	setuid=nocheck
	space=nocheck
	EOF
	# Install pkgutil
	pkgadd -a /tmp/pkgutil-admin -d http://get.opencsw.org/now all
	# Delete the admin file
	rm /tmp/pkgutil-admin
fi

# Install Puppet
echo "Installing Puppet..."
/opt/csw/bin/pkgutil --yes --install puppet3

# Disable SMF service
echo "Disabling svc:/network/cswpuppetd..."
svcadm disable network/cswpuppetd

echo "Puppet installed!"
echo "NOTE: Remember to add /opt/csw/bin to your PATH, if you haven't done so."