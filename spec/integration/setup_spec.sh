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

        It "installs python-build"
            dummy __print_banner

            When call setup_travis_python
            The output should include "version: $TRAVIS_PYTHON_VERSION"
            The output should include "> Installing python-build..."
            The output should include "requested location: $TRAVIS_PYTHON_DIR/builder"
            The output should include "installed version:"
            The result of function "python_build_version" should match pattern 'python-build ????????'
            The variable PATH should start with "$TRAVIS_PYTHON_DIR/builder/bin:"
            The result of function "python_build_location" should equal "$TRAVIS_PYTHON_DIR/builder/bin/python-build"
        End
    End
End
