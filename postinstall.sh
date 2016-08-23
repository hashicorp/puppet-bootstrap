#!/usr/bin/env bash
#
# Post Install Cleanup
#
set -e

PUPPET_ENVIRONMENT=${PUPPET_ENVIRONMENT:-"test"}

if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root." >&2
  exit 1
fi

# Stop the Puppet Agent Service
echo "Stopping Puppet service that is running by default..."
if [[ "${PUPPET_COLLECTION}" != "" ]]; then
  mkdir -p /etc/puppetlabs/code/environments/${PUPPET_ENVIRONMENT}
  puppet resource service mcollective ensure=stopped enable=false
  puppet resource service pxp-agent ensure=stopped enable=false
fi
puppet resource service puppet ensure=stopped enable=false
