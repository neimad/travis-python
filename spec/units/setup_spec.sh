#shellcheck shell=bash

Include ./travis-python

Describe "setup()"
    It "fails when the directory is not specified"
        When run setup
        The status should be failure
        The error should end with "the installation directory must be specified"
    End

    It "fails when the directory name is empty"
        When run setup ""
        The status should be failure
        The error should end with "the installation directory must be specified"
    End

    It "needs the TRAVIS_OS_NAME environment variable to be set"
        unset TRAVIS_OS_NAME

        When run setup "foo"
        The status should be failure
        The error should end with "TRAVIS_OS_NAME: must be set and not null"
    End

    It "needs the TRAVIS_OS_NAME environment variable to be not null"
        export TRAVIS_OS_NAME=

        When run setup "foo"
        The status should be failure
        The error should end with "TRAVIS_OS_NAME: must be set and not null"
    End

    It "fails when the platform is not supported"
        export TRAVIS_OS_NAME=bar

        When call setup "foo"
        The status should be failure
        The error should include "The 'bar' platform is not supported"
    End

    Context "when on a Windows platform"
        Before "TRAVIS_OS_NAME=windows"

        It "installs Chocolatey 0.10.13"
            spy 'choco'

            When call setup "foo"
            The command "choco upgrade chocolatey --yes --version 0.10.13 --allow-downgrade" should be called
            The output should not be blank
        End
    End
End
