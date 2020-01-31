# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright © 2020 Damien Flament
# This file is part of temptree.

TRAVIS_PYTHON_VERSION="0.1.2"
TRAVIS_PYTHON_DIR=$HOME/travis-python

readonly __TRAVIS_PYTHON_SILENT_OUTPUT_FILE=$TRAVIS_PYTHON_DIR/silent_output
readonly __TRAVIS_PYTHON_SILENT_ERROR_FILE=$TRAVIS_PYTHON_DIR/silent_error

readonly __EXIT_FAILURE=1

__print_info() {
    # __print_info <message>
    #
    # Prints the given message to the standard ouput stream in cyan.
    #
    local message=${1:?the message must be specified}

    if [[ -t 1 ]]; then
        message="\033[0;33m$message\033[0m"
    fi

    echo -e "$message"
}

__print_success() {
    # __print_success <message>
    #
    # Prints the given message to the standard ouput stream in green.
    #
    local message=${1:?the message must be specified}

    if [[ -t 1 ]]; then
        message="\033[0;32m$message\033[0m"
    fi

    echo -e "$message"
}

__print_error() {
    # __print_error <message>
    #
    # Prints the given error message to the standard error stream in red.
    #
    local message=${1:?the message must be specified}

    if [[ -t 1 ]]; then
        message="\033[0;31m$message\033[0m"
    fi

    echo -e "$message" >&2
}

__travis_python_error() {
    # __travis_python_error [status]
    #
    # Handles error encountered while running the last command. Many data
    # usefull for debugging are printed to stderr:
    #  - the last command executed,
    #  - its exit status code,
    #  - its output (if it has been silenced usin `__run_silent`),
    #  - the stack trace,
    #  - informations about the execution environment.
    #
    # If the command has been silenced, its output is printed.
    #
    # The status code of the command might be specified.
    #
    local -r status=${1:-$?}

    __strict_mode

    local -r failing_command=$BASH_COMMAND
    local output
    local error
    local -i i
    local -i args_i
    local -i args_left
    local arguments
    local command_line

    __print_error $'\nCommand failed\n--------------'
    __print_error "\`$failing_command\` exited with status $status."

    # Print output of silenced command.
    if [[ -s $__TRAVIS_PYTHON_SILENT_OUTPUT_FILE ]]; then
        output=$(<"$__TRAVIS_PYTHON_SILENT_OUTPUT_FILE")

        if [[ -n $output ]]; then
            __print_error $'\nCommand Standard Output\n-----------------------'
            __print_error "$output"
        fi
    fi

    if [[ -s $__TRAVIS_PYTHON_SILENT_ERROR_FILE ]]; then
        error=$(<"$__TRAVIS_PYTHON_SILENT_ERROR_FILE")

        if [[ -n $error ]]; then
            __print_error $'\nCommand Standard Error\n----------------------'
            __print_error "$error"
        fi
    fi

    # Print the stack trace
    i=0

    if ((i < ${#BASH_LINENO[@]})); then
        __print_error $'\nStack trace\n-----------'

        args_i=$# # skip arguments passed to this handler function

        while ((i < ${#BASH_LINENO[@]})); do
            if ((i == 0)); then
                # The function name is the name of this handler function. Use
                # the failing command instead.
                command_line="$failing_command -> $status"
            else
                command_line=${FUNCNAME[i]}

                if ((BASH_ARGC[i] > 0)); then
                    arguments=

                    for ((args_left = BASH_ARGC[i]; args_left > 0; args_left--)); do
                        arguments="${BASH_ARGV[args_i]} $arguments"
                        ((args_i += 1))
                    done

                    command_line="$command_line $arguments"
                fi
            fi

            __print_error "[$i] $command_line"
            __print_error "  in ${BASH_SOURCE[i]:-<unknown file>} at line ${BASH_LINENO[i]}"

            ((i += 1))
        done
    fi

    # Print information about the environment
    __print_error $'\nEnvironment\n-----------'
    __print_error "Bash $BASH_VERSION"
    __print_error "  invoked as $BASH"
    __print_error "  in process $$."
    __print_error "Working in directory $PWD."
    __print_error "Using PATH: \n  - ${PATH//:/$'\n  - '}"
}

__strict_mode() {
    # __strict_mode
    #
    # Activates the unofficial Bash strict mode.
    #
    # Some Bash behaviors are modified:
    #
    # If a command fails, the shell exits and the `__travis_python_error`
    # functions is executed with the exit status of the failing command as first
    # argument.
    #
    # Any command failing in a pipeline causes the whole pipeline statement to
    # be considered as failing.
    #
    # If an unset parameters is accessed, this is considered as an error.
    #
    # Finally, the `IFS` is set to prevent some misuse.
    #
    set -eEu -o pipefail
    shopt -s extdebug
    IFS=$'\n\t'
    trap '__travis_python_error' ERR
}

__run_silent() {
    # __run_silent <command>
    #
    # Runs a command silently, printing its output in case of error.
    #
    # The specified command is run while capturing its output (on both stdout
    # and stderr). If the command exists with a status code other than 0, its
    # output will be available to the `__travis_python_error` handler.
    #
    __strict_mode

    : "${1:?the command must be specified}"
    local -i status

    # The files are (re)initialized. This is important in order to clear output
    # from a previously silenced command.
    : >"$__TRAVIS_PYTHON_SILENT_OUTPUT_FILE" >"$__TRAVIS_PYTHON_SILENT_ERROR_FILE"

    # Then the stdout and stderr streams are redirected to them.
    set +e
    "$@" >"$__TRAVIS_PYTHON_SILENT_OUTPUT_FILE" 2>"$__TRAVIS_PYTHON_SILENT_ERROR_FILE"
    status=$?
    set -e

    # If the command succeed, the files are cleared.
    if ((status == 0)); then
        : >"$__TRAVIS_PYTHON_SILENT_OUTPUT_FILE" >"$__TRAVIS_PYTHON_SILENT_ERROR_FILE"
    fi

    return $status
}

__trim() {
    # __trim <string>
    #
    # Trims leading and trailing whitespace characters from given string.
    #
    __strict_mode

    local string=${1?the string must be specified}

    shopt -s extglob
    string=${string##+([[:space:]])}
    string=${string%%+([[:space:]])}

    echo "$string"
}

__windows_path() {
    # __windows_path <path>
    #
    # Converts a Unix path to Windows flavor.
    #
    __strict_mode

    local -r path=${1:?the path must be specified}
    local converted
    local drive_letter

    # Convert slashes to backslashes
    converted=${path//\//\\}

    if [[ $converted == \\* ]]; then
        # If it is an absolute path, convert the first component to a drive letter
        drive_letter=$(tr '[:lower:]' '[:upper:]' <<<"${converted:1:1}")
        converted="$drive_letter:${converted:2}"
    fi

    echo "$converted"
}

__latest_matching_version() {
    # __latest_matching_version <specifier> <version>...
    #
    # Gives the latest version matching the specifier from a list of versions.
    #
    # The versions are expected to follow the *semver* specification. The
    # specifier can be a complete version (major.minor.patch) or omit one or
    # more leading components.
    #
    # Only stable versions are considered.
    #
    __strict_mode

    local -r specifier=${1:?the specifier must be specified}
    local -r specifier_pattern=${specifier//./"\."}
    shift
    local versions=("${@:?the versions must be specified}")
    local found_version=""
    local IFS

    if ((${#versions} == 0)); then
        echo "the versions must not be empty" >&2
        return $__EXIT_FAILURE
    fi

    #shellcheck disable=SC2207
    IFS=$'\n' versions=($(sort -V <<<"${versions[*]}"))

    shopt -s extglob

    for version in "${versions[@]}"; do
        if [[ $version =~ ^[[:digit:]]+(\.[[:digit:]]+){2}$ && \
            $version =~ ^${specifier_pattern} ]]; then
            found_version="$version"
        fi
    done

    echo "$found_version"
}

__latest_git_tag() {
    # __latest_git_tag <directory>
    #
    # Gives the latest tag from the Git repository located at the specified
    # directory.
    #
    __strict_mode

    local -r directory=${1:?the directory must be specified}

    git -C "$directory" describe --abbrev=0 --tags
}

__update_git_repo() {
    # __update_git_repo <URL> <directory>
    #
    # Updates the Git repository located at the specified directory from the
    # specified URL.
    #
    # If the repository doesn't exists, it is cloned from the specified URL.
    # Otherwise, it is only fetched.
    # Then, the latest tag is checked out.
    #
    __strict_mode

    local -r url=${1:?the URL must be specified}
    local -r directory=${2:?the directory must be specified}
    local latest_tag

    if [[ ! -d $directory ]]; then
        __run_silent git clone "$url" "$directory"
    else
        __run_silent git -C "$directory" fetch
    fi

    latest_tag=$(__latest_git_tag "$directory")
    __run_silent git -C "$directory" checkout "$latest_tag" --detach
}

__current_builder_version() {
    # __current_builder_version
    #
    # Gives the current version of python-build.
    #
    __strict_mode

    local version

    version=$(python-build --version)
    version="${version#'python-build'}"
    version=$(__trim "$version")

    echo "$version"
}

__install_builder() {
    # __install_builder <directory>
    #
    # Installs python-build to the specified directory.
    #
    # The pyenv distribution is cloned from its Git repository and the latest
    # release is fetched. Then, python-build is installed as a standalone
    # program in the specified directory.
    #
    # The `PATH` is updated to include the `bin` directory and the shell
    # commands hash table is reset.
    #
    __strict_mode

    local directory=${1:?the installation directory must be specified}
    local -r repo_url="https://github.com/pyenv/pyenv"
    local -r clone_directory="/tmp/pyenv"
    local -r installer="$clone_directory/plugins/python-build/install.sh"
    export PATH

    __print_info "Installing latest python-build to $directory..."
    __update_git_repo $repo_url $clone_directory

    PREFIX=$directory $installer

    PATH="$directory/bin:$PATH"
    hash -r

    __print_success "Installed python-build $(__current_builder_version)."
}

__available_python_versions_from_builder() {
    # __available_python_versions_from_builder
    #
    # Gives the list of Python versions available from python-build.
    #
    __strict_mode

    local versions
    local versions=()
    local IFS

    while IFS='' read -r version; do
        version=$(__trim "$version")

        if [[ -n $version ]]; then
            versions+=("$version")
        fi
    done < <(python-build --definitions)

    if ((${#versions[@]} > 0)); then
        IFS=$'\n'
        echo "${versions[*]}"
    fi
}

__available_python_versions_from_chocolatey() {
    # __available_python_versions_from_chocolatey
    #
    # Gives the list of Python versions available from Chocolatey.
    #
    __strict_mode

    local output
    local version
    local versions=()
    local IFS

    output=$(choco list python --exact --all-versions --limit-output)

    while IFS='' read -r version; do
        version=$(__trim "$version")
        version="${version#'python|'}"

        if [[ -n $version ]]; then
            versions+=("$version")
        fi
    done <<<"$output"

    if ((${#versions[@]} > 0)); then
        IFS=$'\n'
        echo "${versions[*]}"
    fi
}

__available_python_versions() {
    # __available_python_versions
    #
    # Gives the list of Python versions available on the current platform.
    #
    __strict_mode

    if [[ $TRAVIS_OS_NAME == "windows" ]]; then
        __available_python_versions_from_chocolatey
    else
        __available_python_versions_from_builder
    fi
}

__current_python_version() {
    # __current_python_version
    #
    # Gives the current version of Python.
    #
    __strict_mode

    local version

    version=$(python --version 2>&1)
    version="${version#'Python'}"
    version=$(__trim "$version")

    echo "$version"
}

install_python() {
    # install_python <directory> <specifier>
    #
    # Installs the latest Python version matching the specified one in the
    # specified directory.
    #
    # The specifier can be a complete version (major.minor.patch) or omit one or
    # more leading components.
    #
    # When OS is Linux or macOS, pyenv is used, on Windows, Chocolatey is used.
    #
    __strict_mode

    local -r location=${1:?the installation directory must be specified}
    local -r specifier=${2:?the specifier must be specified}
    local -a available_versions
    local version
    export PATH

    # shellcheck disable=SC2207
    available_versions=($(__available_python_versions))

    if ((${#available_versions[@]} == 0)); then
        __print_error "No Python version available."
        return $__EXIT_FAILURE
    fi

    version=$(__latest_matching_version "$specifier" "${available_versions[@]}")

    if [[ -z $version ]]; then
        __print_error "No Python version found matching $specifier."
        return $__EXIT_FAILURE
    fi

    __print_info "Installing Python $version..."

    if [[ $TRAVIS_OS_NAME == "windows" ]]; then
        __run_silent choco install python \
            --version="$version" \
            --yes \
            --install-arguments="/quiet InstallAllUsers=0 TargetDir=\"$(__windows_path "$location")\"" \
            --override-arguments \
            --apply-install-arguments-to-dependencies

        PATH="$location:$location/Scripts:$PATH"
    else
        CFLAGS='' __run_silent python-build "$version" "$location"
        PATH="$location/bin:$PATH"
    fi

    hash -r

    __print_success "Installed Python $(__current_python_version)."
}

__travis_python_setup() {
    # __travis_python_setup
    #
    # Setups Python tools for Travis CI for installation within specified
    # directory.
    #
    __strict_mode

    : "${TRAVIS_OS_NAME:?must be set and not null}"

    __print_info "travis-python $TRAVIS_PYTHON_VERSION"

    case $TRAVIS_OS_NAME in
        windows)
            # Workaround for https://github.com/chocolatey/choco/issues/1843
            __run_silent choco upgrade chocolatey --yes --version 0.10.13 --allow-downgrade
            __print_success "Installed Chocolatey $(choco --version)."
            ;;
        linux | osx)
            __install_builder "$TRAVIS_PYTHON_DIR/builder"
            ;;
        *)
            __print_error "The '$TRAVIS_OS_NAME' platform is not supported."
            return $__EXIT_FAILURE
            ;;
    esac

    __print_success "Python tools for Travis CI loaded."
}

${__SOURCED__:+'return'} # Prevent execution while testing

__travis_python_setup
