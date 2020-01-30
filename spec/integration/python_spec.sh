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
        python_--version() {
            python --version
        }

        command_-v_python() {
            command -v python
        }

        It "installs Python ${PYTHON:-$'\b'} to specified directory"
            __travis_python_setup

            When call install_python "$directory/Python" "$PYTHON"
            The line 1 of output should start with "Installing Python $PYTHON"
            The line 2 of output should start with "Installed Python $PYTHON"
            The line 3 of output should be blank
            The result of function "python_--version" should start with "Python $PYTHON"
            The result of function "command_-v_python" should equal "$directory/Python/bin/python"
        End
    End
End
