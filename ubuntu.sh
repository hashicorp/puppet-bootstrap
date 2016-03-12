#!/usr/bin/env bash
#
# This bootstraps Puppet on Ubuntu 12.04 LTS.
#
# To try puppet 4 -->  PUPPET_COLLECTION=pc1 ./ubuntu.sh
#
set -e

# Load up the release information
. /etc/lsb-release

# if PUPPET_COLLECTION is not prepended with a dash "-", add it
[[ "${PUPPET_COLLECTION}" == "" ]] || [[ "${PUPPET_COLLECTION:0:1}" == "-" ]] || \
  PUPPET_COLLECTION="-${PUPPET_COLLECTION}"
[[ "${PUPPET_COLLECTION}" == "" ]] && PINST="puppet" || PINST="puppet-agent"

REPO_DEB_URL="http://apt.puppetlabs.com/puppetlabs-release${PUPPET_COLLECTION}-${DISTRIB_CODENAME}.deb"

#--------------------------------------------------------------------
# NO TUNABLES BELOW THIS POINT
#--------------------------------------------------------------------
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root." >&2
  exit 1
fi

if which puppet > /dev/null 2>&1 && apt-cache policy | grep --quiet apt.puppetlabs.com; then
  echo "Puppet is already installed."
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
apt-get update >/dev/null

# Install Puppet
echo "Installing Puppet..."
DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install ${PINST} >/dev/null

echo "Puppet installed!"

# Install RubyGems for the provider, unless using puppet collections
if [ "$DISTRIB_CODENAME" != "trusty" ]; then
  echo "Installing RubyGems..."
  apt-get --yes install rubygems >/dev/null
fi
if [[ "${PUPPET_COLLECTION}" == "" ]]; then
  gem install --no-ri --no-rdoc rubygems-update
  update_rubygems >/dev/null
fi
