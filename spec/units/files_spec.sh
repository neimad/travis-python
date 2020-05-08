#shellcheck shell=bash

Include ./travis-python.bash

Describe "__init_file()"
    It "fails when the path is not specified"
        When call __init_file
        The status should be failure
        The error should equal "__init_file: the path must be specified"
    End

    It "fails when the path is blank"
        When call __init_file ""
        The status should be failure
        The error should equal "__init_file: the path must be specified"
    End

    Before 'setup_directory'
    After 'cleanup_directory'
    directory=${directory:-}

    It "creates an empty file"
        Path created="$directory/foo"

        When call __init_file "$directory/foo"
        The file created should be exist
        The file created should be file
        The file created should be readable
        The file created should be writable
        The contents of file created should be blank
    End

    It "creates a file in an existing directory"
        Path created="$directory/foo/bar"
        mkdir "$directory/foo"

        When call __init_file "$directory/foo/bar"
        The file created should be exist
        The file created should be file
        The file created should be readable
        The file created should be writable
    End

    It "creates a file and its parent directories"
        Path created="$directory/foo/bar/baz"

        When call __init_file "$directory/foo/bar/baz"
        The file created should be exist
        The file created should be file
        The file created should be readable
        The file created should be writable
    End

    It "overwrites an existing file"
        Path overwritten="$directory/foo"
        touch "$directory/foo"

        with_noclobber() {
            set -o noclobber
            trap 'set +o noclobber' EXIT
            "$@"
        }

        When call with_noclobber __init_file "$directory/foo"
        The file overwritten should be exist
        The file overwritten should be file
        The file overwritten should be readable
        The file overwritten should be writable
        The contents of file overwritten should be blank
    End
End
