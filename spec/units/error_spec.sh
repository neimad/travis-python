#shellcheck shell=bash

Include ./travis-python.bash

Describe "__travis_python_error()"
    It "allows to specify the status of the last command"
        When call __travis_python_error 21
        The status should be success
        The line 4 of error should end with "exited with status 21."
    End

    It "prints the complete command"
        When call __travis_python_error
        The status should be success
        The line 1 of error should be blank
        The line 2 of error should equal "Command failed"
        The line 3 of error should equal "--------------"
        The line 4 of error should match pattern "\`*\` exited with status ?."
    End

    Before 'setup_directory'
    After 'cleanup_directory'
    directory=${directory:-}

    It "prints standard output of the silenced command"
        __TRAVIS_PYTHON_SILENT_OUTPUT_FILE=$directory/output
        echo "output" >"${__TRAVIS_PYTHON_SILENT_OUTPUT_FILE:-}"

        When call __travis_python_error
        The status should be success
        The line 5 of error should be blank
        The line 6 of error should equal "Command standard output"
        The line 7 of error should equal "-----------------------"
        The line 8 of error should equal "output"
    End

    It "prints standard error of the silenced command"
        __TRAVIS_PYTHON_SILENT_ERROR_FILE=$directory/error
        echo "error" >"${__TRAVIS_PYTHON_SILENT_ERROR_FILE:-}"

        When call __travis_python_error
        The status should be success
        The line 5 of error should be blank
        The line 6 of error should equal "Command standard error"
        The line 7 of error should equal "----------------------"
        The line 8 of error should equal "error"
    End

    It "prints information about the environment"
        When call __travis_python_error
        The status should be success
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