#shellcheck shell=bash

Include ./travis-python.bash

Describe "__is_version_greater()"
    It "fails when the version to compare is not specified"
        When call __is_version_greater
        The status should be failure
        The error should equal "__is_version_greater: the version to compare must be specified"
    End

    It "fails when the base version is not specified"
        When call __is_version_greater "1.0.0"
        The status should be failure
        The error should equal "__is_version_greater: the base version must be specified"
    End

    It "considers a blank compared version to be lower"
        When call __is_version_greater "" "1.0.0"
        The status should be failure
    End

    It "considers a blank base version to be lower"
        When call __is_version_greater "1.0.0" ""
        The status should be success
    End

    It "considers the compared version to be lower if its identical to the base one"
        When call __is_version_greater "1.0.0" "1.0.0"
        The status should be failure
    End

    Context
        Parameters
          # version part description        lower version   greater version
            "patch"                         "1.4.2"         "1.4.3"
            "minor"                         "1.4.2"         "1.5.2"
            "major"                         "1.4.2"         "2.4.2"
            "pre-release"                   "1.4.2-alpha"   "1.4.2-beta"
        End

        It "checks if the compared version is greater than the base one regarding the $1 version"
            When call __is_version_greater "$3" "$2"
            The status should be success
        End

        It "checks if the compared version is lower than the base one regarding the $1 version"
            When call __is_version_greater "$2" "$3"
            The status should be failure
        End
    End

    Context
        Parameters
          # greater version description     greater version         lower version description   lower version
            "a beta version"                "2.7.1-beta1"           "an alpha version"          "2.7.1-alpha3"
            "a release candidate version"   "2.7.1-rc2"             "an alpha version"          "2.7.1-alpha3"
            "a release candidate version"   "2.7.1-rc2"             "a beta version"            "2.7.1-beta1"
        End

        It "considers $1 to be greater than $3"
            When call __is_version_greater "$2" "$4"
            The status should be success
        End

        It "considers $3 to be lower than $1"
            When call __is_version_greater "$4" "$2"
            The status should be failure
        End
    End
End

Describe "__latest_matching_version()"
    It "fails when the specifier is not specified"
        When call __latest_matching_version
        The status should be failure
        The error should equal "__latest_matching_version: the version specifier must be specified"
    End

    It "fails when the specifier is blank"
        When call __latest_matching_version ""
        The status should be failure
        The error should equal "__latest_matching_version: the version specifier must be specified"
    End

    Context
        Before 'decrease_travis_python_read_timeout'

        It "fails when input is blank"
            When call __latest_matching_version "1.0"
            The status should be failure
            The error should equal "__latest_matching_version: no input data"
        End
    End

    It "fails when an unknown option is passed"
        Data
            #|1.1.8
            #|1.1.9
            #|1.1.10
        End

        When call __latest_matching_version -z "1.1"
        The status should be failure
        The error should equal "Unknown option 'z'."
    End

    Context
        Parameters
          # specifier description                       specifier   expected result
            "a full specifier"                          "1.0.1"     "1.0.1"
            "a specifier without the patch component"   "2.0"       "2.0.3"
            "a specifier with only the major component" "3"         "3.7.11"
        End

        It "gives the latest version matching $1"
            Data
                #|1.0.1
                #|1.0.2
                #|1.1.0
                #|1.1.1
                #|2.0.1
                #|2.0.2
                #|2.0.3
                #|2.1.0
                #|3.6.1
                #|3.6.2
                #|3.6.3
                #|3.7.11
            End

            When call __latest_matching_version "$2"
            The output should equal "$3"
        End
    End

    It "fails when not any version match"
        Data
            #|1.1.0
            #|2.6.3
            #|3.4.2
        End

        When call __latest_matching_version "1.0"
        The status should be failure
        The error should equal "__latest_matching_version: no matching version"
    End

    It "sorts versions naturally"
        Data
            #|1.1.8
            #|1.1.9
            #|1.1.10
        End

        When call __latest_matching_version "1.1"
        The output should equal "1.1.10"
    End

    It "doesn't need the versions to be sorted"
        Data
            #|1.1.6
            #|1.1.7
            #|1.1.9
            #|1.1.8
        End


        When call __latest_matching_version "1.1"
        The output should equal "1.1.9"
    End

    It "filters development versions"
        Data
            #|3.7.5
            #|3.7-dev
        End

        When call __latest_matching_version "3.7"
        The output should equal "3.7.5"
    End

    It "filters alpha releases"
        Data
            #|3.7.6
            #|3.7.6-a1
            #|3.7.6-a2
        End

        When call __latest_matching_version "3.7"
        The output should equal "3.7.6"
    End

    It "filters beta releases"
        Data
            #|3.7.6
            #|3.7.6-b3
            #|3.7.6-b4
        End

        When call __latest_matching_version "3.7"
        The output should equal "3.7.6"
    End

    It "filters release candidates"
        Data
            #|3.7.6
            #|3.7.6rc2
        End

        When call __latest_matching_version "3.7"
        The output should equal "3.7.6"
    End

    It "filters daily builds"
        Data
            #|3.7.6
            #|3.7.6.20200125
        End

        When call __latest_matching_version "3.7"
        The output should equal "3.7.6"
    End

    It "allows to unfilter alpha releases"
        Data
            #|3.7.6
            #|3.7.6-alpha1
        End

        When call __latest_matching_version -p "3.7"
        The output should equal "3.7.6-alpha1"
    End

    It "allows to unfilter beta releases"
        Data
            #|3.7.6
            #|3.7.6-b3
        End

        When call __latest_matching_version -p "3.7"
        The output should equal "3.7.6-b3"
    End

    It "allows to unfilter release candidates"
        Data
            #|3.7.6
            #|3.7.6-rc2
        End

        When call __latest_matching_version -p "3.7"
        The output should equal "3.7.6-rc2"
    End

    It "does not allow to unfilter daily builds"
        Data
            #|3.7.6
            #|3.7.2.2020125
        End

        When call __latest_matching_version -p "3.7"
        The output should equal "3.7.6"
    End
End
