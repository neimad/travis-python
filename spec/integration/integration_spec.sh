#shellcheck shell=bash

Context "When on Travis CI"
    TRAVIS=${TRAVIS:-}
    Skip if "not on Travis CI" test "$TRAVIS" != "true"

    Before 'setup_directory'
    After 'cleanup_directory'
    directory=${directory:-}

    Describe "travis-python"
        PYTHON=${PYTHON:-}
        Skip if "Python version is not specified" test -z "$PYTHON"

        It "installs Python $PYTHON to specified directory"
            When call ./travis-python "$directory/Python" "$PYTHON"
            The line 1 of output should start with "travis-python"
            The line 2 of output should equal "Python tools for Travis CI."
            The line 3 of output should equal "Installing latest Pyenv to $directory/Python..."
            The line 4 of output should start with "Installed Pyenv"
            The line 5 of output should start with "Installing Python"
            The line 6 of output should start with "Installed Python $PYTHON"
            The line 7 of output should be blank
            The result of function "python --version" should start with "Python $PYTHON"
            The result of function "which python" should equal "$directory/Python/shims/python"
        End
    End
End
