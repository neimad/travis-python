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
        The line 1 of output should equal "Installing latest python-build to $directory..."
        The line 2 of output should equal "Installed python-build 20200110."
        The variable PATH should start with "$directory/bin:"
    End
End

Describe "__available_python_versions_with_builder()"
    It "gets the list of available versions from python-build"
        spy 'python-build'

        When call __available_python_versions_with_builder
        The command "python-build --definitions" should be called
        The output should be blank
    End

    It "filters the ouput of the pyenv command"
        python-build() {
            echo $'   2.3.1\t\n'
            echo $'\t\t3.7.6                     '
            echo $'3.7.7    \t     \t   '
            echo '3.8.0'
            echo $'\n3.8.0-dev '
            echo $'3.8.1  '
            echo $'\tactivepython-3.7.0\n'
            echo $'anaconda-4.0.0    '
        }

        When call __available_python_versions_with_builder
        The output should equal "2.3.1 3.7.6 3.7.7 3.8.0 3.8.0-dev 3.8.1 activepython-3.7.0 anaconda-4.0.0"
    End
End

Describe "__current_builder_version()"
    It "gets the version from python-build output"
        spy 'python-build'

        When call __current_builder_version
        The command "python-build --version" should be called
        The output should be blank
    End

    It "gives the current version of Pyenv"
        stub 'python-build' -o "python-build 20200205"

        When call __current_builder_version
        The output should equal "20200205"
    End
End
