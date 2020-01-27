# shellcheck shell=bash

# FIXTURES_DIR
#
# The base directory where file fixtures will be created.
#
FIXTURES_DIR=$SHELLSPEC_TMPBASE/fixtures
mkdir -p "$FIXTURES_DIR" # FIXME This is not thread-safe !

setup_directory() {
    # setup_directory
    #
    # Creates a temporary directory and assign its location to $directory.
    #
    directory=$(mktemp -d "$FIXTURES_DIR/directory.XXXXXXXXX")
}

cleanup_directory() {
    # cleanup_directory
    #
    # Cleans up the directory located at $directory.
    #
    rm -Rf "$directory"
}
