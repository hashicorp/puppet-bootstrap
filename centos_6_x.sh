#!/usr/bin/env bash
# Bootstrap Puppet on CentOS 6.x
# Tested on CentOS 6.6 64bit

set -e

PUPPET_COLLECTION=${PUPPET_COLLECTION:-"pc1"}
case "${PUPPET_COLLECTION}" in
pc1) PUPPETLABS_RELEASE_RPM="https://yum.puppetlabs.com/puppetlabs-release-${PUPPET_COLLECTION}-el-6.noarch.rpm" ;;
5|6|7)   PUPPETLABS_RELEASE_RPM="https://yum.puppet.com/puppet${PUPPET_COLLECTION}-release-el-6.noarch.rpm" ;;
*)
  echo "Unknown/Unsupported PUPPET_COLLECTION." >&2
  exit 1
esac
PUPPET_PACKAGE=${PUPPET_PACKAGE:-"puppet-agent"}

PATH=$PATH:/opt/puppetlabs/bin
if [ "${EUID}" -ne "0" ]; then
  echo "This script must be run as root." >&2
  exit 1
elif rpm --quiet -q ${PUPPET_PACKAGE}; then
  echo "Puppet $(puppet --version) is already installed."
  exit 0
fi

# Install Puppet Labs repo
echo "Configuring PuppetLabs repo..."
rpm --quiet -i "${PUPPETLABS_RELEASE_RPM}" || true

# Install Puppet
echo "Installing Puppet..."
yum install -q -y ${PUPPET_PACKAGE}

echo "Puppet installed!"
