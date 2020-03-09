#shellcheck shell=bash

Include ./travis-python.bash

Context "When on Travis CI"
    Skip if "not on Travis CI" test "${TRAVIS:-}" != 'true'

    Before 'setup_directory'
    After 'cleanup_directory'
    directory=${directory:-}

    Describe "install_python()"
        Skip if "Python version is not specified" test -z "${PYTHON:-}"

        # Workaround for bug https://github.com/shellspec/shellspec/issues/30
        python_version() {
            python --version 2>&1
        }

        python_location() {
            command -v python
        }

        It "installs Python ${PYTHON:-$'\b'} to specified directory"
            __travis_python_setup

            binary_path=bin/python
            if [[ ${TRAVIS_OS_NAME:-} == 'windows' ]]; then
                binary_path=python
            fi

            When call install_python "$directory/Python" "$PYTHON"
            The line 1 of output should start with "Installing Python $PYTHON"
            The line 2 of output should start with "Installed Python $PYTHON"
            The line 3 of output should be blank
            The result of function "python_version" should start with "Python $PYTHON"
            The result of function "python_location" should equal "$directory/Python/$binary_path"
        End
    End
End
