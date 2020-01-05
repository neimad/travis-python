#shellcheck shell=bash

Include ./travis-python

Describe "print_info()"
    It "fails when the message is not specified"
        When run print_info
        The status should be failure
        The error should end with "the message must be specified"
    End

    It "fails when the message is empty"
        When run print_info ""
        The status should be failure
        The error should end with "the message must be specified"
    End

    It "prints a message to standard output"
        When call print_info  "message"
        The output should equal "message"
    End
End

Describe "print_success()"
    It "fails when the message is not specified"
        When run print_success
        The status should be failure
        The error should end with "the message must be specified"
    End

    It "fails when the message is empty"
        When run print_success ""
        The status should be failure
        The error should end with "the message must be specified"
    End

    It "prints a message to standard output"
        When call print_success  "message"
        The output should equal "message"
    End
End

Describe "print_error()"
    It "fails when the message is not specified"
        When run print_error
        The status should be failure
        The error should end with "the message must be specified"
    End

    It "fails when the message is empty"
        When run print_error ""
        The status should be failure
        The error should end with "the message must be specified"
    End

    It "prints a message to standard error"
        When call print_error "message"
        The status should be failure
        The error should equal "message"
    End
End
