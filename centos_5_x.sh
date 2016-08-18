#!/usr/bin/env bash
# Bootstrap Puppet on CentOS 5.x
# Tested on CentOS 5.11 64bit

set -e

PUPPETLABS_RELEASE_RPM="https://yum.puppetlabs.com/puppetlabs-release-el-5.noarch.rpm"

if [ "${EUID}" -ne "0" ]; then
  echo "This script must be run as root." >&2
  exit 1
elif which puppet > /dev/null 2>&1; then
  echo "Puppet is already installed."
  exit 0
fi

# Install Puppet Labs repo
echo "Configuring PuppetLabs repo..."
repo_path=$(mktemp)
curl -L -o "${repo_path}" "${PUPPETLABS_RELEASE_RPM}" 2>/dev/null
rpm --quiet -i "${repo_path}"
rm "${repo_path}"

# Install Puppet
echo "Installing Puppet..."
yum install -q -y puppet

echo "Puppet installed!"
