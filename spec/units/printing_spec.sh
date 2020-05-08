#shellcheck shell=bash

Include ./travis-python.bash

Describe "__puts()"
    It "prints nothing when the string is omitted"
        When call __puts
        The entire output should be blank
    End

    It "prints the specified string"
        When call __puts "foo"
        The entire output should equal "foo"
    End
End

Describe "__putsn()"
    It "prints a single newline when the string is omitted"
        When call __putsn
        The entire output should equal $'\n'
    End

    It "prints the specified string followed by a newline"
        When call __putsn "foo"
        The entire output should equal $'foo\n'
    End
End

Describe "__colorize()"
    It "fails when the color is not specified"
        When call __colorize
        The status should be failure
        The error should equal "__colorize: the color must be specified"
    End

    It "fails when the color is blank"
        When call __colorize ""
        The status should be failure
        The error should equal "__colorize: the color must be specified"
    End

    It "fails when the specified color is unknown"
        When call __colorize "foo"
        The status should be failure
        The error should equal "__colorize: the color 'foo' is unknown"
    End

    Context
        Before 'decrease_travis_python_read_timeout'

        It "exits if there isn't any input"
            When call __colorize "green"
            The status should be success
        End
    End

    It "keeps a blank line untouched"
        Data
            #|
        End

        When call __colorize "blue"
        The entire output should equal $'\n'
    End

    It "handles a line not terminated by a newline character"
        foo_without_newline() {
            printf '%s' "foo"
        }

        Data foo_without_newline
        When call __colorize "cyan"
        The entire output should equal "foo"
    End

    It "doesn't modify the input when not connected to a terminal"
        Data
            #|foo
            #|bar
            #|baz
        End

        When call __colorize 'red'
        The entire output should equal $'foo\nbar\nbaz\n'
    End
End

Describe "__print_error()"
    It "fails when the message is not specified"
        When call __print_error
        The status should be failure
        The error should equal "__print_error: the message must be specified"
    End

    It "fails when the message is blank"
        When call __print_error ""
        The status should be failure
        The error should equal "__print_error: the message must be specified"
    End

    It "prints a message to standard error"
        When call __print_error "message"
        The error should equal "message"
    End
End

Describe "__print_info()"
    It "fails when the name is not specified"
        When call __print_info
        The status should be failure
        The error should equal "__print_info: the name must be specified"
    End

    It "fails when the name is blank"
        When call __print_info ""
        The status should be failure
        The error should equal "__print_info: the name must be specified"
    End

    It "prints the given name and value to standard output"
        When call __print_info  "foo" "bar"
        The output should equal "  foo: bar"
    End

    It "shows when the value is unspecified"
        When call __print_info "foo"
        The output should equal "  foo: <null>"
    End

    It "shows when the value is blank"
        When call __print_info "foo" ""
        The output should equal "  foo: <null>"
    End
End

Describe "__print_task()"
    It "fails when the task description is not specified"
        When call __print_task
        The status should be failure
        The error should equal "__print_task: the description must be specified"
    End

    It "fails when the task description is blank"
        When call __print_task ""
        The status should be failure
        The error should equal "__print_task: the description must be specified"
    End
End

Describe "__print_task_done()"
    It "prints the 'done' message"
        When call __print_task_done
        The output should equal "  Done."
    End
End

Describe "__print_banner()"
    It "prints the banner"
        When call __print_banner
        The output should not be blank
    End
End
