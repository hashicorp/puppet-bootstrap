#!/usr/bin/env bash
# Bootstrap Puppet on CentOS 6.x
# Tested on CentOS 6.5 64bit

set -e

PUPPETLABS_RELEASE_RPM="http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm"

if [ "${EUID}" -ne "0" ]; then
  /bin/echo "This script must be run as root." >&2
  exit 1
elif /usr/bin/which puppet > /dev/null 2>&1; then
  /bin/echo "Puppet is already installed."
  exit 0
fi

# Install Puppet Labs repo
/bin/echo "Configuring Puppet Labs repo..."
/bin/rpm --quiet -i "${PUPPETLABS_RELEASE_RPM}"

# Install Puppet
/bin/echo "Installing Puppet..."
/usr/bin/yum install -q -y puppet

/bin/echo "Puppet installed!"
