#!/usr/bin/env bash
#
# Bootstrap express script to install/config/start puppet on multi POSIX platforms
# with one line
#
set -e

BOOTSTRAP_TAR_URL=${BOOTSTRAP_TAR_URL:-"https://github.com/edestecd/puppet-bootstrap/archive/master.tar.gz"}

bootstrap_tmp_path=$(mktemp -d -t puppet-bootstrap.XXXXXXXXXX)
curl -sSL "${BOOTSTRAP_TAR_URL}" | tar xz -C "${bootstrap_tmp_path}"
"${bootstrap_tmp_path}/puppet-bootstrap-master/bootstrap.sh" "$@"
