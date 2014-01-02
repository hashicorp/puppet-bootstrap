#!/bin/bash
set -e

#DEBUG=true

function check_root_access {
  # Make sure only root can run our script
  if [[ $EUID -ne 0 ]]; then
     echo "ERROR: This script requires root access" 1>&2
     exit 1
  fi
}

function ensure_package {
  package="$1"

  # Check if the package is installed, and install it if not present
  if hash yum 2>/dev/null; then
    rpm -qi "$package" > /dev/null 2>&1 || yum -y install "$package"
  elif hash apt-get > /dev/null 2>&1; then
    if ! dpkg-query --status "$package" >/dev/null 2>&1; then 
      apt-get -qq update
      apt-get -qq install -y "$package"
    fi
  else
    echo "Yum and apt-get not detected. Unable to install the \"$package\" package."
  fi
}

function ensure_puppet_gpg_key {
  # Check if it's installed already (only on CentOS/RedHat)
  if hash rpm > /dev/null 2>&1 ; then
    rpm -qi gpg-pubkey-4bd6ec30-4ff1e4fa >/dev/null && return
    ensure_package wget
    ensure_package ca_certificates
    rpm --import https://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs
  fi
}

lowercase(){
    echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}

function detect_os {
  # Inspired by http://stackoverflow.com/questions/394230/detect-the-os-from-a-bash-script

  if [ -n "$DIST" ] ; then
    # Avoid running these checks repeatedly even if called again
    return
  fi

  MACH=`uname -m`

  if [ -f /etc/redhat-release ] ; then
    DistroBasedOn='RedHat'
    DIST=`cat /etc/redhat-release |sed s/\ release.*//`
    PSUEDONAME=`cat /etc/redhat-release | sed s/.*\(// | sed s/\)//`
    REV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//`
  elif [ -f /etc/SuSE-release ] ; then
    DistroBasedOn='SuSe'
    PSUEDONAME=`cat /etc/SuSE-release | tr "\n" ' '| sed s/VERSION.*//`
    REV=`cat /etc/SuSE-release | tr "\n" ' ' | sed s/.*=\ //`
  elif [ -f /etc/mandrake-release ] ; then
    DistroBasedOn='Mandrake'
    PSUEDONAME=`cat /etc/mandrake-release | sed s/.*\(// | sed s/\)//`
    REV=`cat /etc/mandrake-release | sed s/.*release\ // | sed s/\ .*//`
  elif [ -f /etc/debian_version ] ; then
    DistroBasedOn='Debian'
    if hash lsb_release ; then
      DIST=`lsb_release --id --short`
      PSUEDONAME=`lsb_release --codename --short`
      REV=`lsb_release --release --short`
    elif [ -f /etc/lsb-release ] ; then
      DIST=`grep '^DISTRIB_ID' /etc/lsb-release | awk -F=  '{ print $2 }'`
      PSUEDONAME=`grep '^DISTRIB_CODENAME' /etc/lsb-release | awk -F=  '{ print $2 }'`
      REV=`grep '^DISTRIB_RELEASE' /etc/lsb-release | awk -F=  '{ print $2 }'`
    elif [ -f /etc/os-release ] ; then
      DIST=`grep '^ID' /etc/os-release | awk -F=  '{ print $2 }'`
      PSUEDONAME=`grep '^VERSION=' /etc/os-release | cut -d '(' -f 2 | cut -d ')' -f 1`
      REV=`grep '^VERSION_ID' /etc/os-release | awk -F=  '{ print $2 }'`
    else
      REV=`cat /etc/debian_version`
    fi
  elif [ -f /etc/arch-release ] ; then
    DistroBasedOn='Arch'
    DIST=$DistroBasedOn
  fi
  DistroBasedOn=`lowercase $DistroBasedOn`
  readonly DIST
  readonly DistroBasedOn
  readonly PSUEDONAME
  readonly REV

  if [ -n "$DEBUG" ] ; then
    echo "DIST: $DIST"
    echo "DistroBasedOn: $DistroBasedOn"
    echo "PSUEDONAME: $PSUEDONAME"
    echo "REV: $REV"
  fi
}

function ensure_puppet {
  check_puppet_installed && echo "Puppet already installed" && return 0 

  ensure_package wget
  detect_os
  case $DistroBasedOn in
    redhat)
      echo "detected redhat-based distro"
      ensure_puppet_gpg_key
      ensure_package ca_certificates
      MAJOR_REV=`echo $REV | cut -d '.' -f 1`
      # Check if it's installed already
      REPO_URL="https://yum.puppetlabs.com/el/${MAJOR_REV}/products/${MACH}/puppetlabs-release-${MAJOR_REV}-7.noarch.rpm"
      rpm -qi puppetlabs-release > /dev/null 2>&1 || rpm -ivh --quiet $REPO_URL || return 1
      ensure_package puppet
      ;;

    debian)
      echo "detected debian based distro"
      if ! dpkg-query --status "puppetlabs-release" >/dev/null 2>&1 ; then
        echo "installing http://apt.puppetlabs.com/puppetlabs-release-${PSUEDONAME}.deb"
        ensure_package ca_certificates
        REPO_URL="https://apt.puppetlabs.com/puppetlabs-release-${PSUEDONAME}.deb"
        repo_path=$(mktemp)
        wget --no-verbose --output-document=${repo_path} ${REPO_URL}
        dpkg -i ${repo_path} && apt-get -qq update || echo "Repo package install failed"
        rm ${repo_path}
        dpkg-query --status "puppetlabs-release" >/dev/null 2>&1 && echo "puppet repo installed successfully"
      else
        echo "puppet repo already installed"
      fi

      ensure_package puppet
      ;;

    arch)
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

function check_puppet_installed {
  if hash puppet > /dev/null 2>&1 && hash facter > /dev/null 2>&1 ; then
    return 0
  else
    return 1
  fi
}

check_root_access

ensure_puppet && echo "puppet and facter currently installed"
