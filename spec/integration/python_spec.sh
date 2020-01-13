#shellcheck shell=bash

Include ./travis-python.bash

Context "When on Travis CI"
    TRAVIS=${TRAVIS:-}
    Skip if "not on Travis CI" test "$TRAVIS" != 'true'

    Before 'setup_directory'
    After 'cleanup_directory'
    directory=${directory:-}

    Describe "install_python()"
        PYTHON=${PYTHON:-}
        Skip if "Python version is not specified" test -z "$PYTHON"

        It "installs Python $PYTHON to specified directory"
            __travis_python_setup

            When call install_python "$directory/Python" "$PYTHON"
            The line 1 of output should start with "Installing Python"
            The line 2 of output should start with "Installed Python $PYTHON"
            The line 3 of output should be blank
            The result of function "python --version" should start with "Python $PYTHON"
            The result of function "which python" should equal "$directory/Python/bin/python"
        End
    End
End
