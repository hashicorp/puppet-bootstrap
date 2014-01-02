#!/bin/bash
set -e

require_root_access() {
  if [[ $EUID -ne 0 ]]; then
     echo "ERROR: This script requires root access" 1>&2
     exit 1
  fi
}

# Check if a package is installed
is_installed() {
  package="$1"
  detect_os
  case $DistroBasedOn in
    redhat)
      rpm -qi "$package" > /dev/null 2>&1 && return 0
      ;;
    debian)
      dpkg-query --status "$package" >/dev/null 2>&1 && return 0
      ;;
    arch)
      pacman -Qi "$package" >/dev/null 2>&1 && return 0
      ;;
    *)
      echo "unknown package management system"
      ;;
  esac
  return 1
}

# Check if the package is installed, and install it if not present
ensure_package_present() {
  package="$1"
  is_installed "$package" && return 0 # return if it's installed already

  detect_os
  case $DistroBasedOn in
    redhat)
      yum -y install "$package"
      ;;
    debian)
      apt-get -qq update
      apt-get -qq install -y "$package"
      ;;
    arch)
      ;;
    *)
      echo "Unable to install \"$package\": unknown package management system"
      ;;
  esac
}

lowercase(){
    #echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
    echo "$1" | tr "[:upper:]" "[:lower:]"
}

# Figure out what distribution or OS we're running on
detect_os() {
  # Inspired by http://stackoverflow.com/questions/394230/detect-the-os-from-a-bash-script

  if [ -n "$DIST" ] ; then
    # Avoid running these checks repeatedly even if called again
    return
  fi

  # Identify major distro type
  if [ -f /etc/redhat-release ] ; then
    DistroBasedOn='RedHat'
  elif [ -f /etc/debian_version ] ; then
    DistroBasedOn='Debian'
  elif [ -f /etc/arch-release ] ; then
    DistroBasedOn='Arch'
  fi
  DistroBasedOn=$(lowercase $DistroBasedOn)

  # Determine further distro details
  # We take this approach to avoid forcing lsb-base package installs
  case $DistroBasedOn in
    redhat)
      DIST=$(cat /etc/redhat-release |sed s/\ release.*//)
      PSUEDONAME=$(cat /etc/redhat-release | sed s/.*\(// | sed s/\)//)
      REV=$(cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//)
      ;;
    debian)
      if hash lsb_release ; then
        DIST=$(lsb_release --id --short)
        PSUEDONAME=$(lsb_release --codename --short)
        REV=$(lsb_release --release --short)
      elif [ -f /etc/lsb-release ] ; then
        DIST=$(grep '^DISTRIB_ID' /etc/lsb-release | awk -F=  '{ print $2 }')
        PSUEDONAME=$(grep '^DISTRIB_CODENAME' /etc/lsb-release | awk -F=  '{ print $2 }')
        REV=$(grep '^DISTRIB_RELEASE' /etc/lsb-release | awk -F=  '{ print $2 }')
      elif [ -f /etc/os-release ] ; then
        DIST=$(grep '^ID' /etc/os-release | awk -F=  '{ print $2 }')
        PSUEDONAME=$(grep '^VERSION=' /etc/os-release | cut -d '(' -f 2 | cut -d ')' -f 1)
        REV=$(grep '^VERSION_ID' /etc/os-release | awk -F=  '{ print $2 }')
      else
        REV=$(cat /etc/debian_version)
      fi
      ;;
    arch)
      # Arch is rolling release based so revision numbers don't apply
      DIST=$DistroBasedOn
      ;;
    *)
      ;;
  esac

  MACH=$(uname -m)
  MAJOR_REV=$(echo $REV | cut -d '.' -f 1)
}

# Idempotent puppet and puppet repository installer
ensure_puppet() {
  is_puppet_installed && echo "Puppet already installed" && return 0 

  ensure_package_present wget
  detect_os
  case $DistroBasedOn in
    redhat)
      echo "detected $DistroBasedOn based distro"
      PUPPETLABS_KEY_URL="http://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs"
      REPO_URL="http://yum.puppetlabs.com/el/${MAJOR_REV}/products/${MACH}/puppetlabs-release-${MAJOR_REV}-7.noarch.rpm"
      # Install GPG key
      rpm -qi gpg-pubkey-4bd6ec30-4ff1e4fa /dev/null 2>&1 || rpm --import "$PUPPETLABS_KEY_URL"
      # Install puppet yum repository
      is_installed puppetlabs-release || rpm -ivh --quiet $REPO_URL
      # Install puppet itself
      ensure_package_present puppet
      ;;

    debian)
      echo "detected $DistroBasedOn based distro"

      # Ensure the puppet repository is available
      if ! is_installed "puppetlabs-release" ; then
        ensure_package_present ca-certificates
        REPO_URL="https://apt.puppetlabs.com/puppetlabs-release-${PSUEDONAME}.deb"
        repo_path=$(mktemp)
        wget --no-verbose --output-document=${repo_path} ${REPO_URL}
        dpkg --install ${repo_path}
        apt-get -qq update
        rm ${repo_path}
        is_installed "puppetlabs-release" && echo "puppet repo installed successfully"
      else
        echo "puppet repo already installed"
      fi

      ensure_package_present puppet
      ;;

    arch)
      echo "detected arch distro"
      # Update the pacman repositories
      pacman -Sy

      # Install Ruby (arch uses gem install of puppet)
      pacman -S --noconfirm --needed ruby
      ;;
    *)
      echo "Unsupported OS - cannot install puppet"
      return 1
      ;;
  esac
}

# Both facter and puppet need to be available
is_puppet_installed() {
  ( hash puppet && hash facter ) > /dev/null 2>&1
}

require_root_access
ensure_puppet && echo "puppet and facter currently installed"
