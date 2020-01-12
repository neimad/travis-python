#shellcheck shell=bash

Include ./travis-python.bash

Describe "current_python_version()"
    It "gets the version from Python output"
        spy 'python'

        When call current_python_version
        The command "python --version" should be called
        The output should be blank
    End

    It "gives the current version of Python"
        stub 'python' -o "Python 3.7.2"

        When call current_python_version
        The output should equal "3.7.2"
    End

    It "gives the current version of Python 2"
        stub 'python' -e "Python 2.7.2"

        When call current_python_version
        The output should equal "2.7.2"
    End
End

Describe "install_python()"
    It "fails when the directory is not specified"
        When run install_python
        The status should be failure
        The error should end with "the installation directory must be specified"
    End

    It "fails when the directory name is empty"
        When run install_python ""
        The status should be failure
        The error should end with "the installation directory must be specified"
    End

    It "fails when the specifier is not given"
        When run install_python "foo"
        The status should be failure
        The error should end with "the specifier must be specified"
    End

    It "fails when the specifier is empty"
        When run install_python "foo" ""
        The status should be failure
        The error should end with "the specifier must be specified"
    End

    Before 'setup_directory'
    After 'cleanup_directory'
    directory=${directory:-}

    Context "when on a Linux platform"
        Before "TRAVIS_OS_NAME=linux"

        It "installs Python using python-build"
            stub 'available_python_versions_with_builder' -o "2.6.4 3.7.1 3.7.2"
            stub 'current_python_version' -s 0 -o "3.7.2"
            spy 'python-build'
            spy 'pyenv'


            When call install_python "$directory" "3.7"
            The line 1 of output should equal "Installing Python 3.7.2..."
            The command "python-build 3.7.2 $directory" should be called
            The command "pyenv" should not be called
            The line 2 of output should equal "Installed Python 3.7.2."
            The variable PATH should start with "$directory/bin:"
        End
    End

    Context "when on a macOS platform"
        Before "TRAVIS_OS_NAME=osx"

        It "installs Python using python-build"
            stub 'available_python_versions_with_builder' -o "2.6.4 3.7.1 3.7.2"
            stub 'current_python_version' -s 0 -o "3.7.2"
            spy 'python-build'
            spy 'pyenv'


            When call install_python "$directory" "3.7"
            The line 1 of output should equal "Installing Python 3.7.2..."
            The command "python-build 3.7.2 $directory" should be called
            The command "pyenv" should not be called
            The line 2 of output should equal "Installed Python 3.7.2."
            The variable PATH should start with "$directory/bin:"
        End
    End

    Context "when on a Windows platform"
        Before "TRAVIS_OS_NAME=windows"

        It "installs Python using Chocolatey"
            spy 'choco'
            stub 'available_python_versions_with_chocolatey' -o "2.6.4 3.7.1 3.7.2"
            stub 'current_python_version' -s 0 -o "3.7.2"

            When call install_python "$directory" "3.7"
            The line 1 of output should equal "Installing Python 3.7.2..."
            The command "choco install python --version=3.7.2" should be called
            The line 2 of output should equal "Installed Python 3.7.2."
            The variable PATH should start with "$directory:$directory/Scripts"
        End
    End
End
