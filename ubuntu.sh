#!/usr/bin/env bash
#
# This bootstraps Puppet on Ubuntu xx.xx LTS.
#
# To try puppet 5 -->  PUPPET_COLLECTION=5 ./ubuntu.sh
#
set -e

# Load up the release information
. /etc/lsb-release

PUPPET_COLLECTION=${PUPPET_COLLECTION:-"pc1"}
case "${PUPPET_COLLECTION}" in
pc1) REPO_DEB_URL="https://apt.puppetlabs.com/puppetlabs-release-pc1-${DISTRIB_CODENAME}.deb" ;;
5|6)   REPO_DEB_URL="https://apt.puppetlabs.com/puppet5-release-${DISTRIB_CODENAME}.deb" ;;
*)
  echo "Unknown/Unsupported PUPPET_COLLECTION." >&2
  exit 1
esac
PUPPET_PACKAGE=${PUPPET_PACKAGE:-"puppet-agent"}

#--------------------------------------------------------------------
# NO TUNABLES BELOW THIS POINT
#--------------------------------------------------------------------
PATH=$PATH:/opt/puppetlabs/bin
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root." >&2
  exit 1
elif dpkg-query --status ${PUPPET_PACKAGE} > /dev/null 2>&1 && apt-cache policy | grep --quiet apt.puppetlabs.com; then
  echo "Puppet $(puppet --version) is already installed."
  exit 0
fi

# Do the initial apt-get update
echo "Initial apt-get update..."
apt-get update >/dev/null

# Install wget if we have to (some older Ubuntu versions)
echo "Installing wget..."
apt-get --yes install wget >/dev/null

# Install the PuppetLabs repo
echo "Configuring PuppetLabs repo..."
repo_deb_path=$(mktemp)
wget --output-document="${repo_deb_path}" "${REPO_DEB_URL}" 2>/dev/null
dpkg -i "${repo_deb_path}" >/dev/null
rm "${repo_deb_path}"

apt-get update >/dev/null

# Install Puppet
echo "Installing Puppet..."
DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install ${PUPPET_PACKAGE} >/dev/null

echo "Puppet installed!"
