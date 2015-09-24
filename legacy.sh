#!/usr/bin/env bash
#
# Detect and purge any known legacy puppet installs
#
set -e

FORCE_LEGACY_ITS_PUPPET=${FORCE_LEGACY_ITS_PUPPET:-""}
FORCE_LEGACY_DFY_PUPPET=${FORCE_LEGACY_DFY_PUPPET:-""}

if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root." >&2
  exit 1
fi

if hash rvm 2>/dev/null; then
  echo "[RVM Found]"
  echo "Clearing rvm default and using system ruby..."
  rvm alias delete default
  unset GEM_HOME IRBRC MY_RUBY_HOME GEM_PATH RUBY_VERSION
  export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/usr/local/rvm/bin

  echo ""
fi

# IT Services Legacy Puppet installed with rvm
if [ -e /usr/local/bin/puppetcheckin.sh ] || [ -n "${FORCE_LEGACY_ITS_PUPPET}" ]; then
  echo "[Legacy ITS Puppet Found]"

  # crons
  echo "Removing Cron..."
  crontab -u root -l |
  grep -v '/usr/local/bin/puppetcheckin.sh' |
  grep -v '# Puppet Name: reportingcron' |
  grep -v '/var/reporting && ./report.pl' |
  crontab -u root -

  # preserve old puppet ssl certs, as tivoli and possible other use this
  echo "Preserving legacy SSL (in /var/lib/puppet/ssl_legacy)..."
  if [ ! -e /var/lib/puppet/ssl_legacy ]; then
    mv /var/lib/puppet/ssl /var/lib/puppet/ssl_legacy
  fi
  if [ -e /etc/init.d/tivoli ]; then
    echo "Editing to reflect legacy SSL/facter location (/etc/init.d/tivoli)"
    sed -i 's~/usr/local/bin/facter~/usr/bin/facter~g' /etc/init.d/tivoli
    sed -i 's~/var/lib/puppet/ssl/~/var/lib/puppet/ssl_legacy/~g' /etc/init.d/tivoli
  fi
  echo "You probably want to edit anything else using Legacy SSL/facter..."

  # binaries/scripts/config/etc
  echo "Removing Files (in /usr/local/bin/ /etc/sysconfig/)..."
  rm -rf /usr/local/bin/facter* /usr/local/bin/puppetcheckin*.sh* /etc/sysconfig/puppet

  echo ""
fi

# Dragonfly Legacy Puppet installed with rvm
if [ -e /usr/local/dragonfly/puppet ] || [ -n "${FORCE_LEGACY_DFY_PUPPET}" ]; then
  echo "[Legacy Dragonfly Puppet Found]"

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

  echo ""
fi
