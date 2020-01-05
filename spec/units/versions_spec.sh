#shellcheck shell=bash

Include ./travis-python

Describe "latest_matching_version()"
    It "fails when the specifier is not specified"
        When run latest_matching_version
        The status should be failure
        The error should end with "the specifier must be specified"
    End

    It "fails when the specifier is empty"
        When run latest_matching_version ""
        The status should be failure
        The error should end with "the specifier must be specified"
    End

    It "fails when no version are specified"
        When run latest_matching_version "1.0"
        The status should be failure
        The error should end with "the versions must be specified"
    End

    It "fails when the versions are empty"
        When run latest_matching_version "1.0" "" "" ""
        The status should be failure
        The error should end with "the versions must not be empty"
    End

    It "fails when not any version match"
        When call latest_matching_version "1.0" "1.1.0" "2.6.3" "3.4.2"
        The status should be failure
        The output should be blank
    End

    It "sorts versions naturally"
        When call latest_matching_version "1.1" "1.1.8" "1.1.9" "1.1.10"
        The output should equal "1.1.10"
    End

    Parameters
        "a full specifier"                          "1.0.1" "1.0.1"
        "a specifier without the patch component"   "2.0"   "2.0.3"
        "a specifier with only the major component" "3"     "3.7.11"
    End

    It "gives the latest version matching $1"
        versions=("1.0.1" "1.0.2" "1.1.0" "1.1.1"
                  "2.0.1" "2.0.2" "2.0.3" "2.1.0"
                  "3.6.1" "3.6.2" "3.6.3" "3.7.11")
        When call latest_matching_version "$2" "${versions[@]}"
        The output should equal "$3"
    End
End
