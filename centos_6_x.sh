#!/usr/bin/env bash
# This bootstraps Puppet on CentOS 6.x
# It has been tested on CentOS 6.4 64bit

repo="https://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm"

[ "$EUID" -ne "0" ]                                     && \
  echo "ERROR:  This script must be run as root." >&2   && \
  exit 1

which puppet &> /dev/null               && \
  echo "Puppet is already installed."   && \
  exit 0

for cmd in {"rpm -i ${repo}","yum install puppet"}; do
  [ ! -z "${verbose}" ] && echo "$cmd"
  $cmd
  rc=$?
  if [ "$rc" -ne "0" ]; then
    echo "ERROR:  Command '$cmd' returned $exit_status"
    exit $exit_status
  fi
done
