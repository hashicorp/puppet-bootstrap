#!/usr/bin/env bash
#
# This bootstraps Puppet on Ubuntu 14.04 LTS.
#
set -e

function installPackage {
  if DEBIAN_FRONTEND=noninteractive bash -c "apt-get -qq -y ${2} install ${1}" >/dev/null; then
    echo "Successfully installed package ${1}"
  else
    echo "Error installing package ${1}"
  fi
}

function isPackageInstalled {
  if dpkg --get-selections | grep -q "^${1}[[:space:]]*install$" >/dev/null; then
    echo "Package ${1} is already installed."
  fi
}
# Load up the release information
. /etc/lsb-release

REPO_DEB_URL="http://apt.puppetlabs.com/puppetlabs-release-${DISTRIB_CODENAME}.deb"

#--------------------------------------------------------------------
# NO TUNABLES BELOW THIS POINT
#--------------------------------------------------------------------
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root." >&2
  exit 1
fi

test=$(isPackageInstalled "puppet")
if [ -n  "$test" ]; then
  exit 0
fi

# Install wget if we have to (some older Ubuntu versions)
test=$(isPackageInstalled "wget")
if [ -z  "$test" ]; then
  # Do the initial apt-get update
  echo "Initial apt-get update..."
  apt-get update >/dev/null
  echo "Installing wget..."
  installPackage 'wget'
fi
# Install the PuppetLabs repo
echo "Configuring PuppetLabs repo..."
repo_deb_path=$(mktemp)
wget --output-document="${repo_deb_path}" "${REPO_DEB_URL}" 2>/dev/null
dpkg -i "${repo_deb_path}" >/dev/null
apt-get update >/dev/null

# Install Puppet
echo "Installing Puppet..."
installPackage 'puppet' "-o Dpkg::Options::=\"--force-confdef\" -o Dpkg::Options::=\"--force-confold\""

# Install RubyGems for the provider
echo "Installing RubyGems..."
if [ $DISTRIB_CODENAME != "trusty" ]; then
  installPackage 'rubygems'
fi
gem install --no-ri --no-rdoc rubygems-update
update_rubygems >/dev/null
