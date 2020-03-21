#!/bin/sh
#===============================================================================
#
#          FILE: run_tests.sh
#
#   DESCRIPTION: Shell wrapper to validate ansible playbooks.
#
#  REQUIREMENTS: Ansible, Bash
#        AUTHOR: Mihai Vultur <mihai.vultur@telenav.com>, SRE Team
#       CREATED: 03/Apr/2019 15:00
#      REVISION:  3
#===============================================================================
set -euo pipefail

# Script Entrypoint
main() {
  CWD="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

  # validate all yaml files ... treat it as warning, return true
  find "${CWD}/.." -name '*.yaml' -o -name '*.yml' | grep -v credentials | xargs yamllint || true
  # run ansible-lint
  find "${CWD}/.." -maxdepth 1 -name '*.yaml' -o -name '*.yml' | grep -v credentials | xargs ansible-lint "$@"
}
#--------------------------
main "$@"


