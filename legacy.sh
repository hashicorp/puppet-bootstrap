#!/usr/bin/env bash
#
# Detect and purge any known legacy puppet installs
#
set -e

if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root." >&2
  exit 1
fi

# IT Services Legacy Puppet installed with rvm
if [ -e /usr/local/bin/puppetcheckin.sh ]; then
  echo "[Legacy ITS Puppet found]"

  # crons
  echo "Removing Legacy ITS Puppet Cron..."
  crontab -u root -l | grep -v '/usr/local/bin/puppetcheckin.sh' | crontab -u root -
  crontab -u root -l | grep -v '/var/reporting && ./report.pl' | crontab -u root -

  # binaries/scripts
  echo "Removing Legacy ITS files (in /usr/local/bin/ /etc/sysconfig/)..."
  rm -rf /usr/local/bin/facter* /usr/local/bin/puppetcheckin*.sh* /etc/sysconfig/puppet
fi

# Dragonfly Legacy Puppet installed with rvm
if [ -e /usr/local/dragonfly/puppet ]; then
  echo "[Legacy Dragonfly Puppet found]"

  # crons
  echo "Removing Legacy Dragonfly Puppet Cron..."
  crontab -u root -l | grep -v 'Puppet Name: puppet-agent' | crontab -u root -
  crontab -u root -l | grep -v 'http_proxy=http://webproxy.mcs.miamioh.edu:80' | crontab -u root -
  crontab -u root -l | grep -v 'https_proxy=http://webproxy.mcs.miamioh.edu:80' | crontab -u root -
  crontab -u root -l | grep -v 'no_proxy=localhost,127.0.0.0/8,*.local,*.mcs.miamioh.edu,pupt001.projectdragonfly.org' | crontab -u root -
  crontab -u root -l | grep -v '/usr/local/dragonfly/puppet/bin/puppet-agent' | crontab -u root -

  # binaries/scripts/var/etc
  echo "Removing Legacy Dragonfly files (in /usr/local/dragonfly/puppet/)..."
  rm -rf /usr/local/dragonfly/puppet
fi
