#shellcheck shell=bash

Include ./travis-python.bash


Describe "__trim()"
    It "exits if there isn't any input"
        When call __trim
        The status should be success
    End

    It "keeps a blank line untouched"
        Data ""
        When call __trim
        The entire output should be blank
    End

    Context
        Parameters
          # spaces description                                  input
            "one leading whitespace"                            " foo"
            "multiple leading whitespaces"                      "   foo"
            "one trailing whitespace"                           "foo "
            "multiple trailing whitespaces"                     "foo   "
            "one leading and one trailing whitespace"           " foo "
            "multiple leading and trailing whitespaces"         "   foo   "
            "one leading tabulation"                            $'\tfoo'
            "one trailing tabulation"                           $'foo\t'
            "multiple leading and trailing space characters"    $' \t foo\t \t'
        End

        It "removes leading and trailing spaces from a line with $1"
            input=$2 # FIXME workaround for https://github.com/shellspec/shellspec/issues/57

            Data "$input"

            When call __trim
            The output should equal "foo"
        End
    End

    It "removes leading and trailing spaces from multiple lines"
        Data:expand
            #|${SHELLSPEC_TAB}foo${SHELLSPEC_TAB}
            #|    foo
            #|foo
            #|  foo ${SHELLSPEC_TAB}
            #|foo      ${SHELLSPEC_TAB}
        End

        When call __trim
        The line 1 of entire output should equal "foo"
        The line 2 of entire output should equal "foo"
        The line 3 of entire output should equal "foo"
        The line 4 of entire output should equal "foo"
        The line 5 of entire output should equal "foo"
        The lines of entire output should equal 5
    End

    It "doesn't remove whitespace characters in the middle of the line"
        Data:expand
            #|f${SHELLSPEC_TAB}oo
            #|fo o
        End

        When call __trim
        The line 1 of entire output should equal "f${SHELLSPEC_TAB}oo"
        The line 2 of entire output should equal "fo o"
        The lines of entire output should equal 2
    End

    It "removes blank lines"
        Data
            #|
            #|foo
            #|
            #|
            #|foo
            #|
            #|
        End

        When call __trim
        The line 1 of entire output should equal "foo"
        The line 2 of entire output should equal "foo"
        The lines of entire output should equal 2
    End

    It "removes lines of space characters"
        Data:expand
            #|${SHELLSPEC_TAB}
            #|foo
            #|${SHELLSPEC_TAB}${SHELLSPEC_TAB}
            #|   ${SHELLSPEC_TAB}
            #|foo
            #| ${SHELLSPEC_TAB}
            #|${SHELLSPEC_TAB}
        End

        When call __trim
        The line 1 of entire output should equal "foo"
        The line 2 of entire output should equal "foo"
        The lines of entire output should equal 2
    End
End


Describe "__strip_prefix()"
    It "fails when the prefix is not specified"
        When run __strip_prefix
        The status should be failure
        The error should end with "the prefix must be specified"
    End

    It "fails when the prefix is blank"
        When run __strip_prefix ""
        The status should be failure
        The error should end with "the prefix must be specified"
    End

    It "exits if there isn't any input"
        When call __strip_prefix "foo"
        The status should be success
    End

    It "keeps a blank line untouched"
        When call __strip_prefix "foo"
        The entire output should be blank
    End

    It "removes the specified prefix"
        Data "foobar"

        When call __strip_prefix "foo"
        The output should equal "bar"
    End

    It "doesn't remove more than one occurence of the specified prefix"
        Data "foofoobar"

        When call __strip_prefix "foo"
        The output should equal "foobar"
    End

    It "doesn't remove the specified prefix in the middle of a string"
        Data "barfoobaz"

        When call __strip_prefix "foo"
        The output should equal "barfoobaz"
    End

    It "doesn't remove the specified prefix at the end of a line"
        Data "barfoo"

        When call __strip_prefix "foo"
        The output should equal "barfoo"
    End

    It "removes the specified prefix from multiple lines"
        Data
            #|foobar
            #|foobaz
        End

        When call __strip_prefix "foo"
        The line 1 of entire output should equal "bar"
        The line 2 of entire output should equal "baz"
        The lines of entire output should equal 2
    End

    It "removes blank lines"
        Data
            #|
            #|
        End

        When call __strip_prefix "foo"
        The entire output should equal ""
    End

    It "removes lines which are blank after stripping"
        Data
            #|foo
            #|foobar
            #|foo
            #|foo
            #|baz
            #|foo
        End

        When call __strip_prefix "foo"
        The line 1 of entire output should equal bar
        The line 2 of entire output should equal baz
        The lines of entire output should equal 2
    End

    It "strips prefixes"
        Data
            #|python|2.4.6
            #|python|2.4.7
            #|python|2.4.8
        End

        When call __strip_prefix "python|"
        The line 1 of entire output should equal "2.4.6"
        The line 2 of entire output should equal "2.4.7"
        The line 3 of entire output should equal "2.4.8"
        The lines of entire output should equal 3
    End
End
