#!/usr/bin/env bash
# Bootstrap Puppet on CentOS 6.x
# Tested on CentOS 6.6 64bit

set -e

PUPPETLABS_RELEASE_RPM="https://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm"

if [ "${EUID}" -ne "0" ]; then
  echo "This script must be run as root." >&2
  exit 1
elif which puppet > /dev/null 2>&1; then
  echo "Puppet is already installed."
  exit 0
fi

# Install Puppet Labs repo
echo "Configuring PuppetLabs repo..."
rpm --quiet -i "${PUPPETLABS_RELEASE_RPM}"

# Install Puppet
echo "Installing Puppet..."
yum install -q -y puppet

echo "Puppet installed!"
