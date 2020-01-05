#shellcheck shell=bash

Include ./travis-python.bash

Describe "windows_path()"
    It "fails when the path is not specified"
        When run windows_path
        The status should be failure
        The error should end with "the path must be specified"
    End

    It "fails when the path is empty"
        When run windows_path ""
        The status should be failure
        The error should end with "the path must be specified"
    End

    Context "when the path is Windows flavor,"
        Parameters
          # description                                 input
            "a relative path"                           "foo\bar"
            "a path relative to the current directory"  ".\foo\bar"
            "a path relative to the parrent directory"  "..\foo\bar"
            "an absolute path"                          "C:\foo\bar"
        End

        It "keeps untouched $1"
            When call windows_path "$2"
            The output should equal "$2"
        End
    End

    Parameters
      # description                                 input           expected output
        "a relative path"                           "foo/bar"       "foo\bar"
        "a path relative to the current directory"  "./foo/bar"     ".\foo\bar"
        "a path relative to the parrent directory"  "../foo/bar"    "..\foo\bar"
        "an absolute path"                          "/c/foo/bar"    "C:\foo\bar"
    End

    It "converts $1 to Windows flavor"
        When call windows_path "$2"
        The output should equal "$3"
    End
End
