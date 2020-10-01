#shellcheck shell=bash

Include ./travis-python.bash

Describe "__available_python_versions()"
    Context "when on a Linux platform"
        Before "TRAVIS_OS_NAME=linux"

        It "gets the list of available versions from python-build"
            spy '__available_python_versions_from_builder'
            spy '__available_python_versions_from_chocolatey'

            When call __available_python_versions
            The command "__available_python_versions_from_builder" should be called
        End
    End

    Context "when on a macOS platform"
        Before "TRAVIS_OS_NAME=osx"

        It "gets the list of available versions from python-build"
            spy '__available_python_versions_from_builder'
            spy '__available_python_versions_from_chocolatey'

            When call __available_python_versions
            The command "__available_python_versions_from_builder" should be called
        End
    End

    Context "when on a Windows platform"
        Before "TRAVIS_OS_NAME=windows"

        It "gets the list of available versions from Chocolatey"
            spy '__available_python_versions_from_chocolatey'
            spy '__available_python_versions_from_builder'

            When call __available_python_versions
            The command "__available_python_versions_from_chocolatey" should be called
        End
    End
End

Describe "__current_python_version()"
    It "gets the version from Python output"
        spy 'python'

        When call __current_python_version
        The command "python --version" should be called
        The output should be blank
    End

    It "gives the current version of Python"
        stub 'python' -o "Python 3.7.2"

        When call __current_python_version
        The output should equal "3.7.2"
    End

    It "gives the current version of Python 2"
        stub 'python' -e "Python 2.7.2"

        When call __current_python_version
        The output should equal "2.7.2"
    End
End

Describe "install_python()"
    It "fails when the directory is not specified"
        When call install_python
        The status should be failure
        The error should equal "install_python: the installation directory must be specified"
    End

    It "fails when the directory name is blank"
        When call install_python ""
        The status should be failure
        The error should equal "install_python: the installation directory must be specified"
    End

    It "fails when the specifier is not given"
        When call install_python "foo"
        The status should be failure
        The error should equal "install_python: the version specifier must be specified"
    End

    It "fails when the specifier is blank"
        When call install_python "foo" ""
        The status should be failure
        The error should equal "install_python: the version specifier must be specified"
    End

    It "fails when an unknown option is passed"
        When call install_python -z "foo" "3.7"
        The status should be failure
        The error should equal "Unknown option 'z'."
    End

    Before 'setup_directory'
    After 'cleanup_directory'
    directory=${directory:-}

    Context
        Before 'setup_travis_variables'

        It "installs Python"
            stub '__available_python_versions' -o "2.6.4 3.7.1 3.7.2"
            stub '__latest_matching_version' -o "3.7.2"
            stub '__current_python_version' -o "3.7.2"
            dummy 'python-build'
            dummy 'choco'

            When call install_python "$directory" "3.7"
            The line 1 of entire output should be blank
            The line 2 of entire output should equal "> Installing Python..."
            The line 3 of entire output should equal "  requested version: 3.7"
            The line 4 of entire output should equal "  pre-release allowed: no"
            The line 5 of entire output should equal "  requested location: $directory"
            The line 6 of entire output should equal "  found version: 3.7.2"
            The line 7 of entire output should equal "  installed version: 3.7.2"
            The line 8 of entire output should equal "  Done."
            The lines of entire output should equal 8
        End

        It "allows to install a pre-release distribution version"
            stub '__available_python_versions' -o "2.6.4 3.7.1 3.7.2-rc2 3.7.2 3.7.3-alpha"
            dummy 'python-build'
            dummy 'choco'
            spy '__latest_matching_version'

            When call install_python -p "$directory" "3.7"
            The command "__latest_matching_version -p 3.7" should be called
            The output should include "pre-release allowed: yes"
        End
    End

    Context "when on a Linux platform"
        Before "TRAVIS_OS_NAME=linux"

        It "installs Python using python-build"
            stub '__available_python_versions' -o "2.6.4 3.7.1 3.7.2"
            stub '__latest_matching_version' -o "3.7.2"
            stub '__current_python_version' -o "3.7.2"
            spy 'python-build'
            spy 'pyenv'

            When call install_python "$directory" "3.7"
            The command "python-build 3.7.2 $directory" should be called
            The command "pyenv" should not be called
            The output should not be blank
            The variable PATH should start with "$directory/bin:"
        End
    End

    Context "when on a macOS platform"
        Before "TRAVIS_OS_NAME=osx"

        It "installs Python using python-build"
            stub '__available_python_versions' -o "2.6.4 3.7.1 3.7.2"
            stub '__latest_matching_version' -o "3.7.2"
            stub '__current_python_version' -o "3.7.2"
            spy 'python-build'
            spy 'pyenv'

            When call install_python "$directory" "3.7"
            The command "python-build 3.7.2 $directory" should be called
            The command "pyenv" should not be called
            The output should not be blank
            The variable PATH should start with "$directory/bin:"
        End
    End

    Context "when on a Windows platform"
        Before "TRAVIS_OS_NAME=windows"

        It "installs Python using Chocolatey"
            spy 'choco'
            stub '__available_python_versions' -o "2.6.4 3.7.1 3.7.2"
            stub '__latest_matching_version' -o "3.7.2"
            stub '__current_python_version' -o "3.7.2"

            When call install_python "$directory" "3.7"
            The command "choco install python --version=3.7.2" should be called
            The output should not be blank
            The variable PATH should start with "$directory:$directory/Scripts"
        End
    End
End
