#shellcheck shell=bash

Include ./travis-python.bash

Context "When on Travis CI"
    Skip if "not on Travis CI" test "${TRAVIS:-}" != 'true'

    Before 'setup_directory' 'setup_travis_python'
    After 'cleanup_directory'
    directory=${directory:-}

    Describe "__available_python_versions()"
        It "gets the list of available versions"
            When call __available_python_versions
            The output should not be blank
        End
    End

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
            setup_travis_python

            When call install_python "$directory/python" "$PYTHON"
            The output should include "> Installing Python..."
            The output should include "requested version: $PYTHON"
            The output should include "found version:"
            The output should include "requested location: $directory/python"
            The output should include "installed version:"
            The result of function "python_version" should match pattern "Python $PYTHON*"
            The result of function "python_location" should equal "$directory/python/bin/python"
        End
    End
End
