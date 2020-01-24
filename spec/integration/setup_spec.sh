#shellcheck shell=bash

Include ./travis-python.bash

Context "When on Travis CI"
    Skip if "not on Travis CI" test "${TRAVIS:-}" != 'true'

    Describe "setup()"
        Context "when on a Linux platform"
            Skip if "not on Linux platform" test "${TRAVIS_OS_NAME:-}" != 'linux'

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
            Skip if "not on macOS platform" test "${TRAVIS_OS_NAME:-}" != 'osx'

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
            Skip if "not on Windows platform" test "${TRAVIS_OS_NAME:-}" != 'windows'

            Todo "downgrades Chocolatey"
        End
    End
End
