#shellcheck shell=bash

Include spec/support/fixtures.sh

Describe "FIXTURES_DIR"
    It "is relative to the Shellspec temporary directory"
        The variable FIXTURES_DIR should equal "$SHELLSPEC_TMPBASE/fixtures"
    End

    Path fixtures="$FIXTURES_DIR"

    It "is created"
        The directory fixtures should be exist
        The directory fixtures should be directory
        The directory fixtures should be readable
        The directory fixtures should be writable
    End
End

Describe "setup_directory()"
    It "creates a directory"
        When call setup_directory
        # shellcheck disable=SC2154
        The directory "$directory" should be exist
        The directory "$directory" should be directory
        The directory "$directory" should be empty directory
        The directory "$directory" should be readable
        The directory "$directory" should be writable
    End

    It "creates the directory within the fixtures directory"
        When call setup_directory
        The variable directory should start with "$FIXTURES_DIR/directory"
    End
End

Describe "cleanup_directory()"
    It "remove the directory created with setup_directory()"
        setup_directory

        Path created="$directory"

        When call cleanup_directory
        The directory created should not be exist
    End
End
