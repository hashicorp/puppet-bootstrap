#!/usr/bin/env bash

# This bootstraps Puppet 4 on CentOS 7.x.
# It has been tested on CentOS 7.2 64bit.

set -e

REPO_URL='https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm'

if [ "$EUID" -ne '0' ]; then
  echo 'This script must be run as root.' >&2
  exit 1
fi

if [ -f /opt/puppetlabs/bin/puppet ]
then
  echo 'Puppet is already installed.'
  exit 0
fi

echo 'Installing Puppet Collection 1 repo.'
yum localinstall -y -q "${REPO_URL}"

echo 'Installing puppet.'
yum install -y -q puppetserver puppet-agent

echo 'Puppet installed.'

# set up symlinks.
ln -s /opt/puppetlabs/puppet/bin/facter /usr/local/bin/
ln -s /opt/puppetlabs/puppet/bin/hiera /usr/local/bin/
ln -s /opt/puppetlabs/puppet/bin/mco /usr/local/bin/
ln -s /opt/puppetlabs/puppet/bin/puppet /usr/local/bin/
ln -s /opt/puppetlabs/server/apps/puppetserver/bin/puppetserver /usr/local/bin/
ln -s -f /opt/puppetlabs/server/apps/puppetdb/bin/puppetdb /usr/local/bin/puppetdb
