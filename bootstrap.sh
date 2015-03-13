#!/usr/bin/env bash
#
# Bootstrap script to install/config/start puppet on multi POSIX platforms
#
set -e

PLATFORM=${PLATFORM:-$1}

# Install Puppet Using the Puppet Labs Package Repositories
case "${PLATFORM}" in
redhat_5|centos_5|centos_5_x)
  sudo ./centos_5_x.sh
  ;;
redhat_6|centos_6|centos_6_x)
  sudo ./centos_6_x.sh
  ;;
redhat_7|centos_7|centos_7_x)
  sudo ./centos_7_x.sh
  ;;
ubuntu)
  sudo ./ubuntu.sh
  ;;
osx|mac_os_x)
  PUPPET_ROOT_GROUP=${PUPPET_ROOT_GROUP:-"wheel"}
  PUPPET_SERVICE=${PUPPET_SERVICE:-"com.puppetlabs.puppet"}
  sudo ./mac_os_x.sh
  ;;
*)
  echo "Unknown/Unsupported PLATFORM." >&2
  echo "Usage: $0 {redhat_5|redhat_6|redhat_7|ubuntu|osx}" >&2
  exit 1
esac

# Configure /etc/puppet/puppet.conf
sudo ./configure.sh

# Start the Puppet Agent Service
sudo ./service.sh

echo "Success!!"
