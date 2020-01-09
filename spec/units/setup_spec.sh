#shellcheck shell=bash

Include ./travis-python.bash

Describe "setup()"
    It "needs the TRAVIS_OS_NAME environment variable to be set"
        unset TRAVIS_OS_NAME

        When run __travis_python_setup "foo"
        The status should be failure
        The error should end with "TRAVIS_OS_NAME: must be set and not null"
    End

    It "needs the TRAVIS_OS_NAME environment variable to be not null"
        export TRAVIS_OS_NAME=

        When run __travis_python_setup "foo"
        The status should be failure
        The error should end with "TRAVIS_OS_NAME: must be set and not null"
    End

    It "fails when the platform is not supported"
        export TRAVIS_OS_NAME=bar

        When call __travis_python_setup "foo"
        The status should be failure
        The error should include "The 'bar' platform is not supported"
        The output should not be blank
    End

    Context "when on a Linux platform"
        Before "TRAVIS_OS_NAME=linux"

        It "shows the tool version"
            dummy 'install_pyenv'

            When call __travis_python_setup "foo"
            The line 1 of output should equal "travis-python $TRAVIS_PYTHON_VERSION"
        End

        It "installs Pyenv"
            spy 'install_pyenv'

            When call __travis_python_setup "foo"
            The command "install_pyenv $HOME/Pyenv" should be called
            The output should not be blank
        End
    End

    Context "when on a macOS platform"
        Before "TRAVIS_OS_NAME=osx"

        It "shows the tool version"
            dummy 'install_pyenv'

            When call __travis_python_setup "foo"
            The line 1 of output should equal "travis-python $TRAVIS_PYTHON_VERSION"
        End

        It "installs Pyenv"
            spy 'install_pyenv'

            When call __travis_python_setup "foo"
            The command "install_pyenv $HOME/Pyenv" should be called
            The output should not be blank
        End
    End

    Context "when on a Windows platform"
        Before "TRAVIS_OS_NAME=windows"

        It "shows the tool version"
            dummy 'choco'

            When call __travis_python_setup "foo"
            The line 1 of output should equal "travis-python $TRAVIS_PYTHON_VERSION"
        End

        It "installs Chocolatey 0.10.13"
            spy 'choco'

            When call __travis_python_setup "foo"
            The command "choco upgrade chocolatey --yes --version 0.10.13 --allow-downgrade" should be called
            The output should not be blank
        End
    End
End
