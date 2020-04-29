#shellcheck shell=bash

Include ./travis-python.bash

Describe "__stderr"
    It "redirects its standard input to standard error stream"
        Data
            #|foo
        End

        When call __stderr
        The error should equal "foo"
    End
End

Describe "__travis_python_error()"
    It "allows to specify the status of the last command"
        When call __travis_python_error -s 21
        The error should include "exited with status 21."
    End

    It "allows to specify the command which failed"
        When call __travis_python_error -c "foo --bar"
        The error should include "
Command failed
==============
foo --bar
"
    End

    It "fails if an unknown option is passed"
        When call __travis_python_error -z
        The status should be failure
        The error should include "illegal option -- z"
    End

    It "prints standard output of the silenced command"
        stub foo -o "output" -s 1
        ! __run_silent foo

        When call __travis_python_error
        The error should include "
Command standard output
-----------------------
output
"
    End

    It "prints standard error of the silenced command"
        stub foo -e "error" -s 1
        ! __run_silent foo

        When call __travis_python_error
        The error should include "
Command standard error
----------------------
error
"
    End

    It "prints information about the environment"
        When call __travis_python_error
        The error should match pattern "*

Environment
-----------
Bash *
  invoked as *
  in process *
  with shell options:
    - *
    - *
    *

Working in directory $PWD.

Using PATH:
  - *
  - *"
    End
End
