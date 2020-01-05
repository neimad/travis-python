#shellcheck shell=bash

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
# set -eu
# IFS=$'\n\t'

shellspec_helper_configure() {
    shellspec_import 'support/doubles'
}

FIXTURES_BASE=$SHELLSPEC_TMPBASE/fixtures
mkdir "$FIXTURES_BASE" # FIXME This is not thread-safe !

setup_directory() {
    # setup_directory
    #
    # Creates a temporary directory and assign its location to $directory.
    #
    directory=$(mktemp -d "$FIXTURES_BASE/directory.XXXXXXXXX")
}

cleanup_directory() {
    # cleanup_directory
    #
    # Cleans up the directory located at $directory.
    #
    rm -Rf "$directory"
}
