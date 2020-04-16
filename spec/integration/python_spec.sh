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
            setup_travis_python

            binary_path=bin/python
            if [[ ${TRAVIS_OS_NAME:-} == 'windows' ]]; then
                binary_path=python
            fi

            When call install_python "$directory/python" "$PYTHON"
            The line 1 of output should be blank
            The line 2 of output should equal "> Installing Python..."
            The line 3 of output should equal "  requested version: $PYTHON"
            The line 4 of output should match pattern "  found version: *"
            The line 5 of output should equal "  requested location: $directory/python"
            The line 6 of output should match pattern "  installed version: *"
            The line 7 of output should equal "  Done."
            The lines of output should equal 7
            The result of function "python_version" should start with "Python $PYTHON"
            The result of function "python_location" should equal "$directory/python/$binary_path"
        End
    End
End
