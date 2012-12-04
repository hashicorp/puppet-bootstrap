#!/usr/bin/env bash
# This bootstraps Puppet on CentOS 5.x
# It has been tested on CentOS 5.6 64bit

set -e

REPO_URL="http://yum.puppetlabs.com/el/5/products/i386/puppetlabs-release-5-6.noarch.rpm"

if [ "$EUID" -ne "0" ]; then
  echo "This script must be run as root." >&2
  exit 1
fi

# Install puppet labs repo
echo "Configuring PuppetLabs repo..."
repo_path=$(mktemp)
wget --output-document=${repo_path} ${REPO_URL} 2>/dev/null
rpm -i ${repo_path} >/dev/null

# Install Puppet...
echo "Installing puppet"
yum install -y puppet > /dev/null

echo "Puppet installed!"