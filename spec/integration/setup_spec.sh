#shellcheck shell=bash

Include ./travis-python.bash

Context "When on Travis CI"
    Skip if "not on Travis CI" test "${TRAVIS:-}" != 'true'

    Describe "setup_travis_python()"
        # Workaround for bug https://github.com/shellspec/shellspec/issues/30
        python_build_version() {
            python-build --version
        }

        python_build_location() {
            command -v python-build
        }

        Context "when on a Unix platform"
            Skip if "not on Unix platform" test "${TRAVIS_OS_NAME:-}" != 'linux' -a "${TRAVIS_OS_NAME:-}" != 'osx'

            It "installs python-build"
                dummy __print_banner

                When call setup_travis_python
                The line 1 of output should equal "  version: $TRAVIS_PYTHON_VERSION"
                The line 2 of output should be blank
                The line 3 of output should equal "> Installing python-build..."
                The line 4 of output should equal "  requested location: $TRAVIS_PYTHON_DIR/builder"
                The line 5 of output should match pattern "  installed version: *"
                The line 6 of output should equal "  Done."
                The lines of output should equal 6
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
