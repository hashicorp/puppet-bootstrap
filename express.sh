#!/usr/bin/env bash
#
# Bootstrap express script to install/config/start puppet on multi POSIX platforms
# with one line
#
set -e

BOOTSTRAP_TAR_URL=${BOOTSTRAP_TAR_URL:-"https://github.com/MiamiOH/puppet-bootstrap/archive/master.tar.gz"}
PLATFORM=${PLATFORM:-$1}

# Attempt to Detect PLATFORM if not set
if [ -z "${PLATFORM}" ]; then
  case "$(uname -s)" in
  Darwin)
    PLATFORM="mac_os_x"
    echo "[Mac OS X Detected]"
    ;;
  Linux)
    # is lsb available to detect distribution info?
    if hash lsb_release 2>/dev/null; then
      lsb_id=$(lsb_release -is)
      lsb_re=$(lsb_release -rs | cut -f1 -d'.')
      case "${lsb_id}" in
      OracleServer)
        PLATFORM="centos_${lsb_re}_x"
        echo "[${lsb_id} ${lsb_re} Detected]"
        ;;
      Ubuntu)
        PLATFORM="ubuntu"
        echo "[${lsb_id} ${lsb_re} Detected]"
        ;;
      esac
    elif [ -e /etc/redhat-release ]; then
      etcrh_re=$(cat /etc/redhat-release | grep -Eo "[[:digit:]]*" | awk 'NR==1')
      PLATFORM="centos_${etcrh_re}_x"
      echo "[Redhat ${etcrh_re} Detected]"
    fi
    ;;
  esac
fi

bootstrap_tmp_path=$(mktemp -d -t puppet-bootstrap.XXXXXXXXXX)
\curl -sSL "${BOOTSTRAP_TAR_URL}" | tar xz -C "${bootstrap_tmp_path}"
source "${bootstrap_tmp_path}/puppet-bootstrap-master/bootstrap.sh" "$@"
