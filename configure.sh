#!/usr/bin/env bash
#
# Configure /etc/puppet/puppet.conf
#
set -e

PUPPET_CERTNAME=${PUPPET_CERTNAME:-$(hostname -f)}
PUPPET_ENVIRONMENT=${PUPPET_ENVIRONMENT:-"test"}
PUPPET_ROOT_GROUP=${PUPPET_ROOT_GROUP:-"root"}

case "${PUPPET_ENVIRONMENT}" in
locdev)      PUPPET_SERVER=${PUPPET_SERVER:-"localhost"} ;;
esodev)      PUPPET_SERVER=${PUPPET_SERVER:-"uitlpupt02.mcs.miamioh.edu"} ;;
esotst)      PUPPET_SERVER=${PUPPET_SERVER:-"uitlpupt02.mcs.miamioh.edu"} ;;
development) PUPPET_SERVER=${PUPPET_SERVER:-"uitlpupp02.mcs.miamioh.edu"} ;;
test)        PUPPET_SERVER=${PUPPET_SERVER:-"uitlpupp02.mcs.miamioh.edu"} ;;
staging)     PUPPET_SERVER=${PUPPET_SERVER:-"uitlpupp02.mcs.miamioh.edu"} ;;
production)  PUPPET_SERVER=${PUPPET_SERVER:-"uitlpupp02.mcs.miamioh.edu"} ;;
*)
  echo "Unknown/Unsupported PUPPET_ENVIRONMENT." >&2
  exit 1
esac

if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root." >&2
  exit 1
fi

echo "Configuring Puppet..."
cat > /etc/puppet/puppet.conf <<-EOF
### File placed by puppet-bootstrap ###
## https://docs.puppetlabs.com/references/3.stable/configuration.html
#

[main]
    vardir = /var/lib/puppet
    logdir = /var/log/puppet
    rundir = /var/run/puppet
    ssldir = \$vardir/ssl

[agent]
    pluginsync      = true
    report          = true
    ignoreschedules = true
    daemon          = false
    ca_server       = ${PUPPET_SERVER}
    certname        = ${PUPPET_CERTNAME}
    environment     = ${PUPPET_ENVIRONMENT}
    server          = ${PUPPET_SERVER}

[user]
    environment = ${PUPPET_ENVIRONMENT}
    parser      = future
EOF
chown root:${PUPPET_ROOT_GROUP} /etc/puppet/puppet.conf
chmod 0644 /etc/puppet/puppet.conf
