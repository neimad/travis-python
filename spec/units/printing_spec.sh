#shellcheck shell=bash

Include ./travis-python.bash

Describe "__print_info()"
    It "fails when the message is not specified"
        When run __print_info
        The status should be failure
        The error should end with "the message must be specified"
    End

    It "fails when the message is empty"
        When run __print_info ""
        The status should be failure
        The error should end with "the message must be specified"
    End

    It "prints a message to standard output"
        When call __print_info  "message"
        The output should equal "message"
    End
End

Describe "__print_success()"
    It "fails when the message is not specified"
        When run __print_success
        The status should be failure
        The error should end with "the message must be specified"
    End

    It "fails when the message is empty"
        When run __print_success ""
        The status should be failure
        The error should end with "the message must be specified"
    End

    It "prints a message to standard output"
        When call __print_success  "message"
        The output should equal "message"
    End
End

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
        The status should be failure
        The error should equal "message"
    End
End
