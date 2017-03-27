#!/usr/bin/env bash
#
# This bootstraps Puppet on Mac OS X 10.10 (Xcode 7.1). It might still work on OS 10.8 and 10.7,
# however this is not guaranteed as those versions are not testable on Travis.
#
# Optional environmental variables:
#   - FACTER_PACKAGE_URL: The URL to the Facter package to install.
#   - PUPPET_PACKAGE_URL: The URL to the Puppet package to install.
#   - HIERA_PACKAGE_URL:  The URL to the Hiera package to install.
#
set -e

#--------------------------------------------------------------------
# Modifiable variables, please set them via environmental variables.
#--------------------------------------------------------------------
FACTER_PACKAGE_URL=${FACTER_PACKAGE_URL:-"https://downloads.puppetlabs.com/mac/facter-1.7.6.dmg"}
PUPPET_PACKAGE_URL=${PUPPET_PACKAGE_URL:-"https://downloads.puppetlabs.com/mac/puppet-3.8.7.dmg"}
HIERA_PACKAGE_URL=${HIERA_PACKAGE_URL:-"https://downloads.puppetlabs.com/mac/hiera-1.3.4.dmg"}

#--------------------------------------------------------------------
# NO TUNABLES BELOW THIS POINT.
#--------------------------------------------------------------------
if [ "$EUID" -ne "0" ]; then
  echo "This script must be run as root." >&2
  exit 1
fi

# This function will download a DMG from a URL, mount it, find
# the `pkg` in it, install that pkg, and unmount the package.
function install_dmg() {
  local name="$1"
  local url="$2"
  local dmg_path=$(mktemp -t "${name}-dmg")

  echo "Installing: ${name}"

  # Download the package into the temporary directory
  echo "-- Downloading DMG..."
  curl -L -o "${dmg_path}" "${url}" 2>/dev/null

  # Mount it
  echo "-- Mounting DMG..."
  local plist_path=$(mktemp -t puppet-bootstrap)
  hdiutil attach -plist "${dmg_path}" > "${plist_path}"
  mount_point=$(grep -E -o '/Volumes/[-.a-zA-Z0-9]+' "${plist_path}")

  # Install. It will be the only pkg in there, so just find any pkg
  echo "-- Installing pkg..."
  pkg_path=$(find "${mount_point}" -name '*.pkg' -mindepth 1 -maxdepth 1)
  installer -pkg "${pkg_path}" -target /

  # Unmount
  echo "-- Unmounting and ejecting DMG..."
  hdiutil eject "${mount_point}" >/dev/null
}

# Install Puppet and Facter and Hiera
install_dmg "Puppet" "${PUPPET_PACKAGE_URL}"
install_dmg "Facter" "${FACTER_PACKAGE_URL}"
install_dmg "Hiera" "${HIERA_PACKAGE_URL}"

# Hide all users from the loginwindow with uid below 500, which will include the puppet user
defaults write /Library/Preferences/com.apple.loginwindow Hide500Users -bool YES
