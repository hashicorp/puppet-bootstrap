#!/usr/bin/env bash
#
# This bootstraps Puppet on Arch Linux.
#
set -e

# Update the pacman repositories
pacman -Sy

# Install Ruby
pacman -S --noconfirm ruby

# Install Puppet and Facter
gem install puppet facter --no-ri --no-rdoc --no-user-install
