# shellcheck shell=bash

setup_travis_variables() {
	# Declares Travis CI specific environment variables.
    #
	# Variables currently supported are:
	# 	- TRAVIS
	# 	- TRAVIS_OS_NAME
	#
    export TRAVIS=true
    export TRAVIS_OS_NAME=

    case $OSTYPE in
        linux*)
            TRAVIS_OS_NAME=linux
            ;;
        darwin*)
            TRAVIS_OS_NAME=osx
            ;;
        cygwin | msys | win32)
            TRAVIS_OS_NAME=windows
            ;;
        *)
            echo "OS type '$OSTYPE' not recognized when simulating Travis CI environment." >&2
            return 1
            ;;
    esac
}
