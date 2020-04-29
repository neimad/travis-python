#shellcheck shell=bash

Include ./travis-python.bash

Describe "__available_python_versions_from_chocolatey()"
    It "gets the list of available versions from Chocolatey"
        spy 'choco'

        When call __available_python_versions_from_chocolatey
        The command "choco list python" should be called
        The output should be blank
    End

    It "filters the ouput of the Chocolatey command"
        stub 'choco' -o $'
            python|2.3.1\t
            \t\tpython|3.7.6
            python|3.7.7    \t     \t
            python|3.8.0
            python|3.8.0-a5
            python|3.8.0-b2
            python|3.8.1
            '

        When call __available_python_versions_from_chocolatey
        The line 1 of output should equal "2.3.1"
        The line 2 of output should equal "3.7.6"
        The line 3 of output should equal "3.7.7"
        The line 4 of output should equal "3.8.0"
        The line 5 of output should equal "3.8.0-a5"
        The line 6 of output should equal "3.8.0-b2"
        The line 7 of output should equal "3.8.1"
        The line 8 of output should be blank
    End

    It "gives a blank output if no version are available"
        stub 'choco' -o ""

        When call __available_python_versions_from_chocolatey
        The output should be blank
    End
End
