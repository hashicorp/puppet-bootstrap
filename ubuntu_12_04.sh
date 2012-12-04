#!/usr/bin/env bash
#
# This bootstraps Puppet on Ubuntu 12.04 LTS.
#
set -e

REPO_DEB_URL="http://apt.puppetlabs.com/puppetlabs-release-precise.deb"

#--------------------------------------------------------------------
# NO TUNABLES BELOW THIS POINT
#--------------------------------------------------------------------
if [ "$EUID" -ne "0" ]; then
  echo "This script must be run as root." >&2
  exit 1
fi

# Install the PuppetLabs repo
echo "Configuring PuppetLabs repo..."
repo_deb_path=$(mktemp)
wget --output-document=${repo_deb_path} ${REPO_DEB_URL} 2>/dev/null
dpkg -i ${repo_deb_path} >/dev/null
apt-get update >/dev/null

# Install Puppet
echo "Installing Puppet..."
apt-get install -y puppet >/dev/null

echo "Puppet installed!"
