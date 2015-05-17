#!/usr/bin/env bash
#
# Start the Puppet Service or Cron
#
set -e

PUPPET_SERVICE=${PUPPET_SERVICE:-"puppet" # "com.puppetlabs.puppet"}

case "${PUPPET_SERVER}" in
localhost)
  PUPPET_CRON_NAM=${PUPPET_CRON_NAM:-"puppet-apply"}
  PUPPET_CRON_CMD=${PUPPET_CRON_CMD:-"/usr/bin/puppet apply --parser future /etc/puppet/manifests"}
  ;;
*)
  PUPPET_CRON_NAM=${PUPPET_CRON_NAM:-"puppet-agent"}
  PUPPET_CRON_CMD=${PUPPET_CRON_CMD:-"/usr/bin/puppet agent --onetime --no-daemonize --splay"}
  ;;
esac

if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root." >&2
  exit 1
fi

# Start the Puppet Agent Service
# echo "Starting Puppet Agent..."
# sudo puppet resource service ${PUPPET_SERVICE} ensure=running enable=true
# Create a Cron Job Instead
echo "Starting Puppet Cron..."
puppet resource cron ${PUPPET_CRON_NAM} ensure=present command="${PUPPET_CRON_CMD}" user=root minute=0
# Force a run to generate ssl sign request
# puppet agent --test || true
