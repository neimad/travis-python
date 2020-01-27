#shellcheck shell=bash

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

shellspec_helper_configure() {
    shellspec_import 'support/doubles'
    shellspec_import 'support/fixtures'
}
