#shellcheck shell=bash

Include ./travis-python.bash

Context "When on Travis CI"
    TRAVIS=${TRAVIS:-}
    Skip if "not on Travis CI" test "$TRAVIS" != 'true'

    Before 'setup_directory'
    After 'cleanup_directory'
    directory=${directory:-}

    Describe "setup()"
        Context "when on a Linux platform"
            Skip if "not on Linux platform" test "$TRAVIS_OS_NAME" != 'linux'

            It "installs python-build"
                When call __travis_python_setup
                The line 1 of output should equal "travis-python $TRAVIS_PYTHON_VERSION"
                The line 2 of output should equal "Installing latest python-build to $HOME/travis-python/builder..."
                The line 3 of output should start with "Installed python-build"
                The line 4 of output should equal "Python tools for Travis CI loaded."
                The result of function "python-build --version" should match 'python-build?????????'
                The variable PATH should start with "$HOME/travis-python/builder/bin:"
                The result of function "which python-build" should equal "$HOME/travis-python/builder/bin/python-build"
            End
        End

        Context "when on a macOS platform"
            Skip if "not on macOS platform" test "$TRAVIS_OS_NAME" != 'osx'

            It "installs python-build"
                When call __travis_python_setup
                The line 1 of output should equal "travis-python $TRAVIS_PYTHON_VERSION"
                The line 2 of output should equal "Installing latest python-build to $HOME/travis-python/builder..."
                The line 3 of output should start with "Installed python-build"
                The line 4 of output should equal "Python tools for Travis CI loaded."
                The result of function "python-build --version" should match 'python-build?????????'
                The variable PATH should start with "$HOME/travis-python/builder/bin:"
                The result of function "which python-build" should equal "$HOME/travis-python/builder/bin/python-build"
            End
        End

        Context "when on a Windows platform"
            Skip if "not on Windows platform" test "$TRAVIS_OS_NAME" != 'windows'

            Todo "downgrades Chocolatey"
        End
    End

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
