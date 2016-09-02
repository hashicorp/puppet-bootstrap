#!/usr/bin/env bash
#
# Start the Puppet Service or Cron
#
set -e

PUPPET_ENVIRONMENT=${PUPPET_ENVIRONMENT:-"test"}

if [[ "${PUPPET_COLLECTION}" == "" ]]; then
  PCONF="/etc/puppet/puppet.conf"
  PMANIFESTS="/etc/puppet/manifests"
  puppet_cmd='/usr/bin/puppet'
  logdest='/var/log/puppet/puppet.log'
else
  PCONF="/etc/puppetlabs/puppet/puppet.conf"
  PMANIFESTS="/etc/puppetlabs/code/environments/${PUPPET_ENVIRONMENT}/manifests"
  puppet_cmd='/opt/puppetlabs/bin/puppet'
  logdest='/var/log/puppetlabs/pxp-agent/puppet.log'
fi

case "${PUPPET_ENVIRONMENT}" in
locdev|loctst|locprd|vagrant)
  PUPPET_CRON_CMD=${PUPPET_CRON_CMD:-"${puppet_cmd} apply --config ${PCONF} --logdest ${logdest} ${PMANIFESTS}"}
  ;;
*)
  PUPPET_CRON_CMD=${PUPPET_CRON_CMD:-"${puppet_cmd} agent --config ${PCONF} --onetime --no-daemonize"}
  ;;
esac

if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root." >&2
  exit 1
fi

# Start the Puppet Agent Service
# echo "Starting Puppet Agent..."
# puppet resource service puppet ensure=running enable=true
# Create a Cron Job Instead
echo "Starting Puppet Cron..."
puppet resource cron puppet ensure=present command="${PUPPET_CRON_CMD}" user=root minute=0
# Force a run to generate ssl sign request
# puppet agent --test || true
