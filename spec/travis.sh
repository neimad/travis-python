#shellcheck shell=bash

shellspec_travis_configure() {
    shellspec_import 'support/travis'

    setup_travis_variables
}
