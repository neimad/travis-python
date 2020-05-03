# shellcheck shell=bash

setup_travis_python_directory() {
    # setup_travis_python_directory
    #
    # Sets up the TRAVIS_PYTHON_DIR environment variable with a fixture
    # directory path.
    #
    export TRAVIS_PYTHON_DIR

    setup_directory
    TRAVIS_PYTHON_DIR=${directory:-}
}

cleanup_travis_python_directory() {
    # cleanup_travis_python_directory
    #
    # Removes the directory pointed by the TRAVIS_PYTHON_DIR environment
    # variable and reset its value.
    #
    export TRAVIS_PYTHON_DIR

    rm -Rf "$TRAVIS_PYTHON_DIR"
    TRAVIS_PYTHON_DIR=
}

decrease_travis_python_read_timeout() {
    # decrease_travis_python_read_timeout
    #
    # The `read` timeout used by travis-python functions is reduced to a minimal
    # functional value.
    #
    # It is intended to speed up test where the input is blank.
    #
    export TRAVIS_PYTHON_READ_TIMEOUT
    local -r bash_release=${BASH_VERSINFO[0]}

    if ((bash_release > 3)); then
        TRAVIS_PYTHON_READ_TIMEOUT=0.1
    else
        TRAVIS_PYTHON_READ_TIMEOUT=1
    fi
}
