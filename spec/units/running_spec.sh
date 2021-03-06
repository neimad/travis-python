#shellcheck shell=bash

Include ./travis-python.bash

Describe "__run_silent()"
    It "fails when the command is not specified"
        When call __run_silent
        The status should be failure
        The error should equal "__run_silent: the command must be specified"
    End

    It "fails when the command is blank"
        When call __run_silent ""
        The status should be failure
        The error should equal "__run_silent: the command must be specified"
    End

    It "runs a command"
        spy 'foo'

        When call __run_silent foo
        The command "foo" should be called
    End

    It "runs a command passing arguments"
        spy 'foo'

        When call __run_silent foo --with arguments
        The command "foo --with arguments" should be called
    End

    It "runs a command silently"
        stub 'foo' -o "Foo output" -e "Foo error"

        When call __run_silent foo
        The output should be blank
        The error should be blank
    End

    It "makes the output of the command available"
        stub 'foo' -o "Foo output" -e "Foo error" -s 25

        Path output="$TRAVIS_PYTHON_DIR/$__TRAVIS_PYTHON_SILENT_OUTPUT_FILENAME"
        Path error="$TRAVIS_PYTHON_DIR/$__TRAVIS_PYTHON_SILENT_ERROR_FILENAME"

        When call __run_silent foo
        The status should equal 25
        The contents of file output should equal "Foo output"
        The contents of file error should equal "Foo error"
    End
End
