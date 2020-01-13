#shellcheck shell=bash

Include ./travis-python.bash

Describe "__available_python_versions_with_chocolatey()"
    It "gets the list of available versions from Chocolatey"
        spy 'choco'

        When call __available_python_versions_with_chocolatey
        The command "choco list python" should be called
        The output should be blank
    End

    It "filters the ouput of the Chocolatey command"
        choco() {
            echo $'   python|2.3.1\t\n'
            echo $'\t\tpython|3.7.6                     '
            echo $'python|3.7.7    \t     \t   '
            echo 'python|3.8.0'
            echo $'\npython|3.8.0-a5 '
            echo $'\npython|3.8.0-b2 '
            echo $'python|3.8.1  '
        }

        When call __available_python_versions_with_chocolatey
        The output should equal "2.3.1 3.7.6 3.7.7 3.8.0 3.8.0-a5 3.8.0-b2 3.8.1"
    End
End
