#shellcheck shell=bash

Include ./travis-python.bash

Describe "__install_builder()"
    It "fails when the directory is not specified"
        When run __install_builder
        The status should be failure
        The error should end with "the installation directory must be specified"
    End

    It "fails when the directory is empty"
        When run __install_builder
        The status should be failure
        The error should end with "the installation directory must be specified"
    End

    Before 'setup_directory'
    After 'cleanup_directory'
    directory=${directory:-}

    It "installs the builder to the specified directory"
        spy '__update_git_repo'
        spy "/tmp/pyenv/plugins/python-build/install.sh"
        stub '__current_builder_version' -o "20200110"

        When call __install_builder "$directory"
        The command "__update_git_repo https://github.com/pyenv/pyenv /tmp/pyenv" should be called
        The command "/tmp/pyenv/plugins/python-build/install.sh" should be called
        The line 1 of output should be blank
        The line 2 of output should equal "> Installing python-build..."
        The line 3 of output should equal "  requested location: $directory"
        The line 4 of output should equal "  installed version: 20200110"
        The line 5 of output should equal "  Done."
        The lines of output should equal 5
        The variable PATH should start with "$directory/bin:"
    End
End

Describe "__available_python_versions_from_builder()"
    It "gets the list of available versions from python-build"
        spy 'python-build'

        When call __available_python_versions_from_builder
        The command "python-build --definitions" should be called
        The output should be blank
    End

    It "filters the ouput of the python-build command"
        stub 'python-build' -o $'
            2.3.1\t
            \t\t3.7.6
            3.7.7    \t     \t
            3.8.0
            3.8.0-dev
            3.8.1
            \tactivepython-3.7.0
            anaconda-4.0.0
            '

        When call __available_python_versions_from_builder
        The line 1 of output should equal "2.3.1"
        The line 2 of output should equal "3.7.6"
        The line 3 of output should equal "3.7.7"
        The line 4 of output should equal "3.8.0"
        The line 5 of output should equal "3.8.0-dev"
        The line 6 of output should equal "3.8.1"
        The line 7 of output should equal "activepython-3.7.0"
        The line 8 of output should equal "anaconda-4.0.0"
        The lines of output should equal 8
    End

    It "gives an empty output if no version are available"
        stub 'python-build' -o ""

        When call __available_python_versions_from_builder
        The output should be blank
    End
End

Describe "__current_builder_version()"
    It "gets the version from python-build output"
        spy 'python-build'

        When call __current_builder_version
        The command "python-build --version" should be called
        The output should be blank
    End

    It "gives the current version of python-build"
        stub 'python-build' -o "python-build 20200205"

        When call __current_builder_version
        The output should equal "20200205"
    End
End
