#shellcheck shell=bash

Include ./travis-python

Describe "install_pyenv()"
    It "fails when the directory is not specified"
        When run install_pyenv
        The status should be failure
        The error should end with "the installation directory must be specified"
    End

    It "fails when the directory is empty"
        When run install_pyenv
        The status should be failure
        The error should end with "the installation directory must be specified"
    End

    Before 'setup_directory'
    After 'cleanup_directory'
    directory=${directory:-}

    It "installs Pyenv to the specified directory"
        spy 'update_git_repo'
        stub 'current_pyenv_version' -o "1.2.3"

        When call install_pyenv "$directory"
        The command "update_git_repo https://github.com/pyenv/pyenv $directory" should be called
        The line 1 of output should equal "Installing latest Pyenv to $directory..."
        The line 2 of output should equal "Installed Pyenv 1.2.3."
        The variable PYENV_ROOT should equal "$directory"
        The variable PATH should start with "$directory/bin:$directory/shims"
    End
End

Describe "available_python_versions_with_pyenv()"
    It "gets the list of available versions from Pyenv"
        spy 'pyenv'

        When call available_python_versions_with_pyenv
        The command "pyenv install --list" should be called
        The output should be blank
    End

    It "filters the ouput of the pyenv command"
        pyenv() {
            echo $'   2.3.1\t\n'
            echo $'\t\t3.7.6                     '
            echo $'3.7.7    \t     \t   '
            echo '3.8.0'
            echo $'\n3.8.0-dev '
            echo $'3.8.1  '
            echo $'\tactivepython-3.7.0\n'
            echo $'anaconda-4.0.0    '
        }

        When call available_python_versions_with_pyenv
        The output should equal "2.3.1 3.7.6 3.7.7 3.8.0 3.8.0-dev 3.8.1 activepython-3.7.0 anaconda-4.0.0"
    End
End

Describe "current_pyenv_version()"
    It "gets the version from Pyenv output"
        spy 'pyenv'

        When call current_pyenv_version
        The command "pyenv --version" should be called
        The output should be blank
    End

    It "gives the current version of Pyenv"
        stub 'pyenv' -o "pyenv 1.2.3"

        When call current_pyenv_version
        The output should equal "1.2.3"
    End
End
