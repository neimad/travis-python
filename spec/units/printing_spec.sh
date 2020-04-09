#shellcheck shell=bash

Include ./travis-python.bash

Describe "__print_error()"
    It "fails when the message is not specified"
        When run __print_error
        The status should be failure
        The error should end with "the message must be specified"
    End

    It "fails when the message is empty"
        When run __print_error ""
        The status should be failure
        The error should end with "the message must be specified"
    End

    It "prints a message to standard error"
        When call __print_error "message"
        The error should equal "message"
    End
End

Describe "__print_info()"
    It "fails when the name is not specified"
        When run __print_info
        The status should be failure
        The error should end with "the name must be specified"
    End

    It "fails when the name is empty"
        When run __print_info ""
        The status should be failure
        The error should end with "the name must be specified"
    End

    It "fails when the value is not specified"
        When run __print_info "foo"
        The status should be failure
        The error should end with "the value must be specified"
    End

    It "fails when the value is empty"
        When run __print_info "foo" ""
        The status should be failure
        The error should end with "the value must be specified"
    End

    It "prints the given name and value to standard output"
        When call __print_info  "foo" "bar"
        The output should equal "  foo: bar"
    End
End

Describe "__print_task()"
    It "fails when the task description is not specified"
        When run __print_task
        The status should be failure
        The error should end with "the description must be specified"
    End

    It "fails when the task description is empty"
        When run __print_task ""
        The status should be failure
        The error should end with "the description must be specified"
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
