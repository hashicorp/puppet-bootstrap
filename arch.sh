#!/usr/bin/env bash
#
# This bootstraps Puppet on Arch Linux.
#
set -e

# Verify we're running as root
if [ "$EUID" -ne "0" ]; then
  echo "This script must be run as root." >&2
  exit 1
fi

# Update the pacman repositories
pacman -Sy

# Install Ruby
pacman -S --noconfirm --needed ruby

# Install Puppet and Facter
gem install puppet facter --no-ri --no-rdoc --no-user-install

# Create the Puppet group so it can run
groupadd puppet

cp `gem contents puppet | grep puppet.service` /usr/lib/systemd/system
