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
  echo "Removing Cron..."
  crontab -u root -l |
  grep -v '/usr/local/bin/puppetcheckin.sh' |
  grep -v '# Puppet Name: reportingcron' |
  grep -v '/var/reporting && ./report.pl' |
  crontab -u root -

  # preserve old puppet ssl certs, as tivoli and possible other use this
  echo "Preserving legacy SSL (in /var/lib/puppet/ssl_legacy)..."
  echo "You probably want to edit anything using this (/etc/init.d/tivoli)"
  mv /var/lib/puppet/ssl /var/lib/puppet/ssl_legacy

  # binaries/scripts/config/etc
  echo "Removing Files (in /usr/local/bin/ /etc/sysconfig/)..."
  rm -rf /usr/local/bin/facter* /usr/local/bin/puppetcheckin*.sh* /etc/sysconfig/puppet
fi

# Dragonfly Legacy Puppet installed with rvm
if [ -e /usr/local/dragonfly/puppet ]; then
  echo "[Legacy Dragonfly Puppet found]"

  # crons
  echo "Removing Cron..."
  crontab -u root -l |
  grep -v 'Puppet Name: puppet-agent' |
  grep -v 'http_proxy=http://webproxy.mcs.miamioh.edu:80' |
  grep -v 'https_proxy=http://webproxy.mcs.miamioh.edu:80' |
  grep -v 'no_proxy=localhost,127.0.0.0/8,\*.local,\*.mcs.miamioh.edu' |
  grep -v '/usr/local/dragonfly/puppet/bin/puppet-agent' |
  crontab -u root -

  # binaries/scripts/config/etc
  echo "Removing Files (in /usr/local/dragonfly/puppet/)..."
  rm -rf /usr/local/dragonfly/puppet
fi
