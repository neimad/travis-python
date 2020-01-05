#shellcheck shell=bash disable=SC2218

Include spec/support/doubles.sh

Describe "SPY_DIR"
    It "is relative to the Shellspec temporary directory"
        The variable SPY_DIR should equal "$SHELLSPEC_TMPBASE/spy"
    End

    Path spy="$SPY_DIR"

    It "is created"
        The directory spy should be exist
        The directory spy should be directory
        The directory spy should be readable
        The directory spy should be writable
    End
End

Describe "spy()"
    It "fails when the program is not specified"
        When run spy
        The status should be failure
        The error should end with "the program must be specified"
    End

    It "fails when the program name is empty"
        When run spy ""
        The status should be failure
        The error should end with "the program must be specified"
    End

    It "makes the program do nothing"
        foo() {
            echo "FOO"
            echo "BAR" >&2
            return 42
        }

        When call spy "foo" && foo
        The output should be blank
        The error should be blank
        The status should be success
    End

    It "records the calls to the spied program"
        spy 'foo'
        Path spy-calls="$SPY_CALLS_FILE"

        When call foo; foo "bar"
        The line 1 of contents of file spy-calls should equal "foo"
        The line 2 of contents of file spy-calls should equal "foo bar"
    End
End

Describe "spy_check()"
    It "fails when the command line is not specified"
        When run spy_check
        The status should be failure
        The error should end with "the command line must be specified"
    End

    It "fails when the command line is empty"
        When run spy_check ""
        The status should be failure
        The error should end with "the command line must be specified"
    End

    It "finds a command line related to a spied program"
        spy 'foo'
        foo "bar"

        When call spy_check "foo bar"
        The status should be success
    End

    It "does not find a command line related to a not spied program"
        foo() { :; }

        foo "bar"

        When call spy_check "foo bar"
        The status should be failure
    End
End

Describe "spy_dump()"
    It "shows the calls to the spied program"
        foo() { :; }

        spy 'foo'
        foo "bar"

        When call spy_dump
        The output should equal "
Spy Report
----------
foo bar"
    End

    It "shows an empty report if not any program have been spied"
        When call spy_dump
        The output should equal "
Spy Report
----------"
    End

    It "show the calls to multiple spied program"
        foo() { :; }
        bar() { :; }
        baz() { :; }

        spy 'foo'
        spy 'baz'

        foo "bar"
        foo "bar" "baz"
        bar
        bar "bar"
        baz "foo"
        foo "baz"
        foo

        When call spy_dump
        The output should equal "
Spy Report
----------
foo bar
foo bar baz
baz foo
foo baz
foo"
    End
End

Describe "stub()"
    It "fails when the program is not specified"
        When run stub
        The status should be failure
        The error should end with "the program must be specified"
    End

    It "fails when the program is empty"
        When run stub ""
        The status should be failure
        The error should end with "the program must be specified"
    End

    foo() {
        echo "FOO"
        echo "BAR" >&2
        return 42
    }

    It "makes the program do nothing by default"
        stub 'foo'

        When call foo
        The output should be blank
        The error should be blank
        The status should be success
    End

    It "makes the program output on stdout"
        stub 'foo' -o "foo stub output"

        When call foo
        The output should equal "foo stub output"
    End

    It "makes the program output on stderr"
        stub 'foo' -e "foo stub error"

        When call foo
        The error should equal "foo stub error"
    End

    It "set the program exit status"
        stub 'foo' -s 23

        When call foo
        The status should equal 23
    End

    It "does all of this at the same time"
        stub 'foo' -o "foo stub output" -e "foo stub error" -s 23

        When call foo
        The output should equal "foo stub output"
        The error should equal "foo stub error"
        The status should equal 23
    End
End
