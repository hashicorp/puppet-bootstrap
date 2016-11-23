#!/bin/bash
set -e

require_root_access() {
  if [[ $EUID -ne 0 ]]; then
     echo "ERROR: This script requires root access"
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
  echo "installing $package and dependencies..."

  detect_os
  case $DistroBasedOn in
    redhat)
      yum -y --quiet install "$package"
      ;;
    debian)
      apt-get -qq update
      apt-get -qq install -y "$package" > /dev/null
      ;;
    arch)
      # Update the pacman repositories
      pacman -Sy

      # Install Ruby (arch uses gem install of puppet)
      pacman -S --noconfirm --needed "$package"
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
  OS_DESCRIPTION="Detected ${DistroBasedOn}-based distro: $DIST $PSUEDONAME $REV for $MACH"
  case $DistroBasedOn in
    redhat)
      echo "$OS_DESCRIPTION"
      REPO_URL="https://yum.puppetlabs.com/el/${MAJOR_REV}/products/${MACH}/puppetlabs-release-${MAJOR_REV}-7.noarch.rpm"
      # Install GPG key
      if ! rpm -qi gpg-pubkey-4bd6ec30-4ff1e4fa > /dev/null 2>&1 ; then 
        gpg_key=$(mktemp)
        gpg --recv-key --trust-model direct --keyserver pool.sks-keyservers.net 4BD6EC30
        gpg --export --armor 47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30 > $gpg_key
        echo "Installing puppetlabs GPG key"
        rpm --import $gpg_key
        rm $gpg_key
        rpm -qi gpg-pubkey-4bd6ec30-4ff1e4fa > /dev/null 2>&1 && echo "Puppet GPG key installed successfully" || echo "Error: Puppet GPG key install failed"
      fi

      if ! is_installed puppetlabs-release ; then
        # Install puppet yum repository
        echo "installing puppetlabs yum repository from $REPO_URL"
        repo_path="$(mktemp).rpm"
        wget --quiet --output-document=${repo_path} ${REPO_URL}
        yum -y --quiet install $repo_path
        rm $repo_path
        is_installed puppetlabs-release && echo "Puppetlabs yum repo installed sucessfully" || echo "Error: puppetlabs repo install failed"
      fi
      # Install puppet itself
      ensure_package_present puppet
      ;;

    debian)
      echo "$OS_DESCRIPTION"

      # Ensure the puppet repository is available
      if ! is_installed "puppetlabs-release" ; then
        echo "Puppetlabs repository not detected. Installing..."

        REPO_URL="https://apt.puppetlabs.com/puppetlabs-release-${PSUEDONAME}.deb"
        repo_path=$(mktemp)
        wget --quiet --output-document=${repo_path} ${REPO_URL}
        dpkg --install ${repo_path}
        apt-get -qq update
        rm ${repo_path}
        is_installed "puppetlabs-release" && echo "puppetlabs repository installed successfully"
      else
        echo "puppet repo already installed"
      fi

      # Install puppet
      ensure_package_present puppet
      ;;

    arch)
      echo "detected arch distro"

      # Install Puppet and Facter as ruby gems
      ensure_gem puppet
      ensure_gem facter
      ensure_group puppet

      ;;
    *)
      echo "Unsupported OS - cannot install puppet"
      return 1
      ;;
  esac
}

is_gem_installed() {
  gem list | grep -q "${gem} ("
}

ensure_gem() {
  gem="$1"
  ensure_package_present ruby
  if ! is_gem_installed "$gem" ; then
    gem install "$gem" --no-ri --no-rdoc --no-user-install
    is_gem_installed "$gem" || exit 1
  fi
}

ensure_group() {
  [ -z "$1" ] && exit 1
  group="$1"
  if ! getent group "$group" > /dev/null 2>&1 ; then
    groupadd "$group"
  fi

}

# Both facter and puppet need to be available
is_puppet_installed() {
  ( hash puppet && hash facter ) > /dev/null 2>&1
}

require_root_access

# Install puppet if it's not installed already
if is_puppet_installed ; then
  echo "Puppet and facter already installed"
  exit 0
else
  echo "No existing puppet install detected"
  echo "Preparing to install puppet and facter"
  ensure_puppet
fi

# Verify puppet install before telling user it's installed
echo "Verifying that puppet and facter installed successfully..."
if is_puppet_installed ; then
  echo "Detected puppet version $(puppet -V)"
  echo "Detected facter version $(facter --version)"
  echo "Puppet and facter installed successfully"
else
  echo "Error: puppet and/or facter not detected following install attempt"
  exit 1
fi

