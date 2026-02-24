#!/usr/bin/env bash
# This adds hiera.yaml

cat << EOF > /etc/puppet/hiera.yaml
:backends:
  - yaml

:hierarchy:
  - 'nodes/%{::hostname}'
  - 'roles/%{::role}'
  - 'default'

:yaml:
:datadir: '/etc/puppet/hieradata'

:merge_behavior: deeper
EOF
