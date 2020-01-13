#shellcheck shell=bash

Include ./travis-python.bash

Describe "__latest_git_tag()"
    It "fails when the directory is not specified"
        When run __latest_git_tag
        The status should be failure
        The error should end with "the directory must be specified"
    End

    It "fails when the directory name is empty string"
        When run __latest_git_tag ""
        The status should be failure
        The error should end with "the directory must be specified"
    End

    It "asks Git for the latest tag"
        spy 'git'

        When run __latest_git_tag "foo"
        The command "git -C foo describe --abbrev=0 --tags" should be called
    End
End

Describe "__update_git_repo()"
    It "fails when the URL is not specified"
        When run __update_git_repo
        The status should be failure
        The error should end with "the URL must be specified"
    End

    It "fails when the URL is empty"
        When run __update_git_repo ""
        The status should be failure
        The error should end with "the URL must be specified"
    End

    It "fails when the directory is not specified"
        When run __update_git_repo "https://foo"
        The status should be failure
        The error should end with "the directory must be specified"
    End

    It "fails when the directory name is empty string"
        When run __update_git_repo "https://foo" ""
        The status should be failure
        The error should end with "the directory must be specified"
    End

    Before 'setup_directory'
    After 'cleanup_directory'
    directory=${directory:-}

    It "clones a new repository"
        cleanup_directory
        spy 'git'

        When call __update_git_repo 'https://foo' "$directory"
        The command "git clone https://foo $directory" should be called
    End

    It "updates an existing repository"
        spy 'git'

        When call __update_git_repo 'https://foo' "$directory"
        The command "git -C $directory fetch" should be called
        The command "git clone" should not be called
    End

    It "loads the latest tag"
        stub '__latest_git_tag' -o '1.2.3' -s 25
        spy 'git'

        When call __update_git_repo 'https://foo' "$directory"
        The command "git -C $directory checkout 1.2.3" should be called
    End
End
