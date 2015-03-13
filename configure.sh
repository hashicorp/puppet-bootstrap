#!/usr/bin/env bash
#
# Configure /etc/puppet/puppet.conf
#
set -e

PUPPET_SERVER=${PUPPET_SERVER:-"pupt001.projectdragonfly.org"}
PUPPET_ENVIRONMENT=${PUPPET_ENVIRONMENT:-"staging"}
PUPPET_ROOT_GROUP=${PUPPET_ROOT_GROUP:-"root"}

if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root." >&2
  exit 1
fi

echo "Configuring Puppet..."
cat > /etc/puppet/puppet.conf <<-EOF
# Deployment puppet.conf config for puppet
# WARNING: this file has been automatically setup by puppet-bootstrap
# Please make changes there and rerun setup, not here, as they will be overwritten....
#
# http://docs.puppetlabs.com/references/latest/configuration.html
#

[main]
    # The Puppet log directory.
    # The default value is '\$vardir/log'.
    logdir = \$vardir/log

    # Where Puppet PID files are kept.
    # The default value is '\$vardir/run'.
    rundir = \$vardir/run

    # Where SSL certificates are kept.
    # The default value is '\$confdir/ssl'.
    ssldir = \$vardir/ssl

    server = ${PUPPET_SERVER}
    masterport = 8140
    report = true
    pluginsync = true

[agent]
    # The file in which puppetd stores a list of the classes
    # associated with the retrieved configuratiion.  Can be loaded in
    # the separate ``puppet`` executable using the ``--loadclasses``
    # option.
    # The default value is '\$confdir/classes.txt'.
    classfile = \$vardir/classes.txt

    # Where puppetd caches the local configuration.  An
    # extension indicating the cache format is added automatically.
    # The default value is '\$confdir/localconfig'.
    localconfig = \$vardir/localconfig

    environment = ${PUPPET_ENVIRONMENT}
    runinterval = 60m
    splay = true
    splaylimit = 20m
    #ignorecache = true
EOF
chown root:${PUPPET_ROOT_GROUP} /etc/puppet/puppet.conf
chmod 0644 /etc/puppet/puppet.conf
