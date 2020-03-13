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
