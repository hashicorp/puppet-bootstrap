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
      RedHatEnterpriseServer|CentOS|OracleServer|EnterpriseEnterpriseServer)
        PLATFORM="centos_${lsb_re}_x"
        echo "[${lsb_id} ${lsb_re} Detected]"
        ;;
      Ubuntu)
        PLATFORM="ubuntu"
        echo "[${lsb_id} ${lsb_re} Detected]"
        ;;
      esac
    elif [ -e /etc/system-release ]; then
      DISTR=$(cat /etc/system-release | cut -f1 -d' ')
      etcsys_re=$(cat /etc/system-release | grep -o [0-9] | head -n 1)
      PLATFORM="${DISTR}_${etcsys_re}_x"
      echo "[${PLATFORM} Detected]"
      case "${DISTR}" in
	      Amazon)
          PLATFORM="centos_7_x"
      esac
      echo "[Treated as ${PLATFORM}]"
    fi
    ;;

  esac
fi

bootstrap_tmp_path=$(mktemp -d -t puppet-bootstrap.XXXXXXXXXX)
if hash curl 2>/dev/null; then
  \curl -sSL "${BOOTSTRAP_TAR_URL}" | tar xz -C "${bootstrap_tmp_path}"
elif hash wget 2>/dev/null; then
  \wget -qO - "${BOOTSTRAP_TAR_URL}" | tar xz -C "${bootstrap_tmp_path}"
else
  echo "Can't find curl or wget to download puppet-bootstrap" >&2
  exit 1
fi
source "${bootstrap_tmp_path}/puppet-bootstrap-master/bootstrap.sh" "$@"
