#!/usr/bin/env bash
#
# Start the Puppet Agent Service or Cron
#
set -e

PUPPET_SERVICE=${PUPPET_SERVICE:-"puppet" # "com.puppetlabs.puppet"}
PUPPET_CRON=${PUPPET_CRON:-"/usr/bin/puppet agent --onetime --no-daemonize --splay"}

# Start the Puppet Agent Service
# echo "Starting Puppet Agent..."
# sudo puppet resource service ${PUPPET_SERVICE} ensure=running enable=true
# Create a Cron Job Instead
echo "Starting Puppet Cron..."
sudo puppet resource cron puppet-agent ensure=present command="${PUPPET_CRON}" user=root minute=0
