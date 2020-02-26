#shellcheck shell=bash

Include ./travis-python.bash

Context "When on Travis CI"
    Skip if "not on Travis CI" test "${TRAVIS:-}" != 'true'

    Describe "__travis_python_setup()"
        # Workaround for bug https://github.com/shellspec/shellspec/issues/30
        python_build_version() {
            python-build --version
        }

        python_build_location() {
            command -v python-build
        }

        Context "when on a Linux platform"
            Skip if "not on Linux platform" test "${TRAVIS_OS_NAME:-}" != 'linux'

            It "installs python-build"
                When call __travis_python_setup
                The line 1 of output should equal "travis-python $TRAVIS_PYTHON_VERSION"
                The line 2 of output should equal "Installing latest python-build to $TRAVIS_PYTHON_DIR/builder..."
                The line 3 of output should start with "Installed python-build"
                The line 4 of output should equal "Python tools for Travis CI loaded."
                The line 5 of output should be blank
                The result of function "python_build_version" should match pattern 'python-build ????????'
                The variable PATH should start with "$TRAVIS_PYTHON_DIR/builder/bin:"
                The result of function "python_build_location" should equal "$TRAVIS_PYTHON_DIR/builder/bin/python-build"
            End
        End

        Context "when on a macOS platform"
            Skip if "not on macOS platform" test "${TRAVIS_OS_NAME:-}" != 'osx'

            It "installs python-build"
                When call __travis_python_setup
                The line 1 of output should equal "travis-python $TRAVIS_PYTHON_VERSION"
                The line 2 of output should equal "Installing latest python-build to $TRAVIS_PYTHON_DIR/builder..."
                The line 3 of output should start with "Installed python-build"
                The line 4 of output should equal "Python tools for Travis CI loaded."
                The result of function "python_build_version" should match pattern 'python-build ????????'
                The variable PATH should start with "$TRAVIS_PYTHON_DIR/builder/bin:"
                The result of function "python_build_location" should equal "$TRAVIS_PYTHON_DIR/builder/bin/python-build"
            End
        End

        Context "when on a Windows platform"
            Skip if "not on Windows platform" test "${TRAVIS_OS_NAME:-}" != 'windows'

            Todo "downgrades Chocolatey"
        End
    End
End
