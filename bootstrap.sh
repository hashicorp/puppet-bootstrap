#!/usr/bin/env bash
#
# Bootstrap script to install/config/start puppet on multi POSIX platforms
#
set -e

PLATFORM=${PLATFORM:-$1}
PUPPET_ENVIRONMENT=${PUPPET_ENVIRONMENT:-$2}
PUPPET_SERVER=${PUPPET_SERVER:-$3}

if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root." >&2
  exit 1
fi

# Install Puppet Using the Puppet Labs Package Repositories
case "${PLATFORM}" in
redhat_5|centos_5|centos_5_x) source ./centos_5_x.sh ;;
redhat_6|centos_6|centos_6_x) source ./centos_6_x.sh ;;
redhat_7|centos_7|centos_7_x) source ./centos_7_x.sh ;;
debian) source ./debian.sh ;;
ubuntu) source ./ubuntu.sh ;;
osx|mac_os_x)
  PUPPET_ROOT_GROUP=${PUPPET_ROOT_GROUP:-"wheel"}
  PUPPET_SERVICE=${PUPPET_SERVICE:-"com.puppetlabs.puppet"}
  source ./mac_os_x.sh
  ;;
*)
  echo "Unknown/Unsupported PLATFORM." >&2
  echo "Usage: $0 {redhat_5|redhat_6|redhat_7|debian|ubuntu|osx} [environment] [server]" >&2
  exit 1
esac

# Configure /etc/puppet/puppet.conf
source ./configure.sh

# Start the Puppet Agent Service
source ./service.sh

echo "Success!!"
