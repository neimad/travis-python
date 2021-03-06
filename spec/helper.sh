#shellcheck shell=bash

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

shellspec_helper_configure() {
    shellspec_import 'support/doubles'
    shellspec_import 'support/fixtures'
    shellspec_import 'support/travis-python'

    shellspec_before 'setup_travis_python_directory'
    shellspec_after 'cleanup_travis_python_directory'
}
