#shellcheck shell=bash

Include ./travis-python.bash

Describe "trim()"
    It "fails when the string is not specified"
        When run trim
        The status should be failure
        The error should end with "the string must be specified"
    End

    It "keeps an empty string untouched"
        When call trim ""
        The output should equal ""
    End

    It "does not remove spaces within a string"
        When call trim $'stri \t\nng'
        The output should equal $'stri \t\nng'
    End

    Parameters
      # spaces description                          input
        "one leading whitespace"                    " string"
        "multiple leading whitespaces"              "   string"
        "one trailing whitespace"                   "string "
        "multiple trailing whitespaces"             "string   "
        "one leading and one trailing whitespace"   " string "
        "multiple leading and trailing whitespaces" "   string   "
        "one leading tabulation"                    $'\tstring'
        "one trailing tabulation"                   $'string\t'
        "one leading line feed"                     $'\nstring'
        "one trailing line feed"                    $'string\n'
        "multiple leading and trailing space characters" $' \n\n\tstring\t\n \t'
    End


    It "removes leading and trailing spaces from a string with $1"
        When call trim "$2"
        The output should equal "string"
    End
End
