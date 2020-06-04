#shellcheck shell=bash

Include ./travis-python.bash

Describe "setup_travis_python()"
    It "shows the tool version"
        dummy '__print_banner'
        dummy '__install_builder'

        When call setup_travis_python
        The line 1 of output should equal "  version: $TRAVIS_PYTHON_VERSION"
    End

    It "installs python-build"
        spy '__install_builder'

        When call setup_travis_python
        The command "__install_builder $TRAVIS_PYTHON_DIR/builder" should be called
        The output should not be blank
    End
End
