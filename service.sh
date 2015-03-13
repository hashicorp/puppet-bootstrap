#!/usr/bin/env bash
#
# Start the Puppet Agent Service or Cron
#
set -e

PUPPET_SERVICE=${PUPPET_SERVICE:-"puppet" # "com.puppetlabs.puppet"}
PUPPET_CRON=${PUPPET_CRON:-"/usr/bin/puppet agent --onetime --no-daemonize --splay"}

if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root." >&2
  exit 1
fi

# Start the Puppet Agent Service
# echo "Starting Puppet Agent..."
# sudo puppet resource service ${PUPPET_SERVICE} ensure=running enable=true
# Create a Cron Job Instead
echo "Starting Puppet Cron..."
puppet resource cron puppet-agent ensure=present command="${PUPPET_CRON}" user=root minute=0
# Force a run to generate ssl sign request
puppet agent --test || true
