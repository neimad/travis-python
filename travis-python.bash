# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright © 2020 Damien Flament
# This file is part of travis-python.

TRAVIS_PYTHON_VERSION="1.1.0"
: "${TRAVIS_PYTHON_DIR:=$HOME/travis-python}"
: "${TRAVIS_PYTHON_READ_TIMEOUT:=10}"

__TRAVIS_PYTHON_SILENT_OUTPUT_FILENAME=silent_output
__TRAVIS_PYTHON_SILENT_ERROR_FILENAME=silent_error

readonly __EXIT_FAILURE=1
readonly __EXIT_SUCCESS=0

__travis_python_error() {
    # __travis_python_error [-c <command>] [-s <status>]
    #
    # Handles error encountered while running the last command. Many data
    # usefull for debugging are printed to stderr:
    #  - the last command executed,
    #  - its exit status code,
    #  - its output (if it has been silenced using `__run_silent`),
    #  - the stack trace,
    #  - informations about the execution environment.
    #
    # If the command has been silenced, its output is printed.
    #
    # The command and its status code might be specified.
    #
    local OPT
    local OPTIND
    local status=$?
    local failing_command=$BASH_COMMAND
    local -r silent_output_file=$TRAVIS_PYTHON_DIR/$__TRAVIS_PYTHON_SILENT_OUTPUT_FILENAME
    local -r silent_error_file=$TRAVIS_PYTHON_DIR/$__TRAVIS_PYTHON_SILENT_ERROR_FILENAME
    local -i i
    local -i args_i
    local -i args_left
    local arguments
    local command_line

    while getopts 'c:s:' OPT; do
        case $OPT in
            c)
                failing_command=$OPTARG
                ;;
            s)
                status=$OPTARG
                ;;
            *) return $__EXIT_FAILURE ;;
        esac
    done

    local -r status
    local -r failing_command

    __stderr <<EOF

Command failed
==============
$failing_command
    exited with status $status.
EOF

    # Print output of silenced command.
    if [[ -s $silent_output_file ]]; then
        __stderr <<EOF

Command standard output
-----------------------
$(<"$silent_output_file")
EOF
    fi

    if [[ -s $silent_error_file ]]; then
        __stderr <<EOF

Command standard error
----------------------
$(<"$silent_error_file")
EOF
    fi

    # Print the stack trace
    if ((${#BASH_LINENO[@]} > 0)); then
        __stderr <<EOF

Stack trace
-----------
EOF

        i=0
        args_i=$# # skip arguments passed to this handler function

        while ((i < ${#BASH_LINENO[@]})); do
            if ((i == 0)); then
                # The function name is the name of this handler function. Use
                # the failing command instead.
                command_line="$failing_command -> $status"
            else
                command_line=${FUNCNAME[i]}

                if ((BASH_ARGC[i] > 0)); then
                    # NOT_COVERED_START
                    arguments=

                    for ((args_left = BASH_ARGC[i]; args_left > 0; args_left--)); do
                        arguments="${BASH_ARGV[args_i]} $arguments"
                        ((args_i += 1))
                    done

                    command_line="$command_line $arguments"
                    # NOT_COVERED_STOP
                fi
            fi

            __stderr <<EOF
[$i] $command_line
  in ${BASH_SOURCE[i]:-'<unknown file>'} at line ${BASH_LINENO[i]}
EOF

            ((i += 1))
        done
    fi

    # Print information about the environment
    local -r shell_options="${SHELLOPTS//:/$'\n    - '}"
    local -r command_paths="${PATH//:/$'\n  - '}"

    __stderr <<EOF

Environment
-----------
Bash $BASH_VERSION
  invoked as $BASH
  in process $$
  with shell options:
    - $shell_options

Working in directory $PWD.

Using PATH:
  - $command_paths
EOF
}

__be_strict() {
    # __be_strict
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
    # If an unset parameter is expanded, this is considered as an error.
    #
    # Finally, the `IFS` is set to prevent some misuse.
    #
    # Because this script is sourced and Travis CI functions does not like the
    # strict mode, behaviors are disabled when on a Travis CI machine:
    #  - expanding unset parameters is not treated as an error.
    #
    export __ORIG_IFS
    export IFS

    set -o errexit
    set -o errtrace
    set -o pipefail
    set -o nounset
    shopt -s extdebug
    __ORIG_IFS="${IFS:-}"
    IFS=$'\n\t'
    trap '__travis_python_error -s "$?" -c "$BASH_COMMAND"' ERR
}

__be_kind() {
    # __be_kind
    #
    # Desactivates the unofficial Bash strict mode.
    #
    # Everything set using the function __be_strict is reverted.
    #
    set +o errexit
    set +o errtrace
    set +o pipefail
    set +o nounset
    shopt -u extdebug
    IFS="$__ORIG_IFS"
    trap '' ERR
}

__stderr() {
    # __stderr
    #
    # Redirects the standard input to standard output while coloring it in red.
    #
    __colorize "red" >&2
}

__puts() {
    # __puts <string>
    #
    # Sends the given string to standard output.
    #
    printf "%s" "${1-}"
}

__putsn() {
    # __putsn <string>
    #
    # Sends the given string to standard output, followed by a newline.
    #
    printf "%s\n" "${1-}"
}

__colorize() {
    # __colorize <color>
    #
    # Apply the specified foreground color to the received input and send it to
    # standard output.
    #
    __required "${1:-}" "the color" || return

    local -r CSI=$'\e['
    local -r reset="${CSI}m"
    # shellcheck disable=SC2034
    local -r \
        code_black=30 \
        code_red=31 \
        code_green=32 \
        code_yellow=33 \
        code_blue=34 \
        code_magenta=35 \
        code_cyan=36 \
        code_white=37
    local -r color=$1
    local -r code_name=code_${color}
    local -r code=${!code_name:-}
    local line

    if [[ -z $code ]]; then
        __error "the color '$color' is unknown" || return
    fi

    # Print each line of input
    while IFS= read -r -t "$TRAVIS_PYTHON_READ_TIMEOUT" line; do
        if [[ -t 1 ]]; then
            # NOT_COVERED_START
            __puts "$reset"
            __puts "${CSI}${code}m"
            # NOT_COVERED_STOP
        fi

        __putsn "$line"

        if [[ -t 1 ]]; then
            # NOT_COVERED_START
            __puts "$reset"
            # NOT_COVERED_STOP
        fi
    done

    # If the last line isn't terminated by a newline character, print it now.
    if ((${#line} > 0)); then
        if [[ -t 1 ]]; then
            # NOT_COVERED_START
            __puts "$reset"
            __puts "${CSI}${code}m"
            # NOT_COVERED_STOP
        fi

        __puts "$line"

        if [[ -t 1 ]]; then
            # NOT_COVERED_START
            __puts "$reset"
            # NOT_COVERED_STOP
        fi
    fi
}

__error() {
    # __error <message>
    #
    # Prints the given error message to standard error in red, prefixed by the
    # name of the caller and returns _EXIT_FAILURE.
    #
    __putsn "${FUNCNAME[1]}: ${1:-}" | __stderr

    return $__EXIT_FAILURE
}

__required() {
    # __required <value> <description>
    #
    # If the given value is not null, do nothing.
    # Otherwize, prints an error message according to the given description to
    # standard error in red, prefixed by the name of the caller and return
    # __EXIT_FAILURE.
    #
    if [[ -z ${1:-} ]]; then
        __putsn "${FUNCNAME[1]}: ${2:-} must be specified" | __stderr

        return $__EXIT_FAILURE
    fi
}

__print_error() {
    # __print_error <message>
    #
    # Prints the given error message to the standard error stream in red.
    #
    __required "${1:-}" "the message" || return

    local -r message=$1

    __putsn "$message" | __colorize "red" >&2
}

__print_info() {
    # __print_info <name> <value>
    #
    # Prints the given name and value to the standard ouput stream.
    #
    __required "${1:-}" "the name" || return

    local -r name=$1
    local -r value=${2:-'<null>'}

    __puts "  $name:" | __colorize "yellow"
    __putsn " $value"
}

__print_task() {
    # __print_task <description>
    #
    # Prints a message to standard output showing that a task started.
    #
    __required "${1:-}" "the description" || return

    local -r description=$1

    __putsn
    __puts ">" | __colorize "yellow"
    __putsn " $description..."
}

__print_task_done() {
    # __print_task_done
    #
    # Prints a message to standard output showing that the task finished.
    #
    __putsn "  Done." | __colorize "green"
}

__print_banner() {
    # __print_banner
    #
    # Prints the banner.
    #
    __colorize "blue" <<EOF
888                             d8b
888                             Y8P
888
888888 888d888 8888b.  888  888 888 .d8888b
888    888P"      "88b 888  888 888 88K
888    888    .d888888 Y88  88P 888 "Y8888b.
Y88b.  888    888  888  Y8bd8P  888      X88   888    888
 "Y888 888    "Y888888   Y88P   888  88888P'   888    888
                                               888    888
                             88888b.  888  888 888888 88888b.   .d88b.  88888b.
                             888 "88b 888  888 888    888 "88b d88""88b 888 "88b
                             888  888 888  888 888    888  888 888  888 888  888
                             888 d88P Y88b 888 Y88b.  888  888 Y88..88P 888  888
                             88888P"   "Y88888  "Y888 888  888  "Y88P"  888  888
                             888           888
                             888      Y8b d88P
                             888       "Y88P"
EOF
}

__trim() {
    # __trim
    #
    # Trims leading and trailing whitespace characters from each line of stdin
    # and output it to stdout.
    #
    # Lines which are blank after trimming are not send to output.
    #
    local line

    while read -r -t "$TRAVIS_PYTHON_READ_TIMEOUT" line; do
        shopt -s extglob

        line=${line##+([[:space:]])}
        line=${line%%+([[:space:]])}

        if ((${#line} > 0)); then
            __putsn "$line"
        fi
    done
}

__strip_prefix() {
    # __strip_prefix <prefix>
    #
    # Removes the specified prefix from each line of stdin and output it to
    # stdout.
    #
    # Lines which are blank after stripping are not send to output.
    #
    __required "${1:-}" "the prefix" || return

    local -r prefix=$1
    local line

    while read -r -t "$TRAVIS_PYTHON_READ_TIMEOUT" line; do
        if [[ ${line:0:${#prefix}} == "$prefix" ]]; then
            line=${line:${#prefix}}
        fi

        if ((${#line} > 0)); then
            __putsn "$line"
        fi
    done

}

__is_version_greater() {
    # __is_version_greater <version> <base>
    #
    # Checks if the specified version is greater than the specified base
    # version.
    #
    # The versions are expected to follow the *semver* specification.
    # Only stable versions are considered.
    #
    case $# in
        0)
            __error "the version to compare must be specified" || return
            ;;
        1)
            __error "the base version must be specified" || return
            ;;
    esac

    local -r version=$1
    local -r base=$2
    local -i i
    local -a version_parts
    local -a base_parts

    IFS='.-' read -r -a version_parts <<<"$version"
    IFS='.-' read -r -a base_parts <<<"$base"

    for i in {0..2}; do
        if ((version_parts[i] > base_parts[i])); then
            return $__EXIT_SUCCESS
        elif ((version_parts[i] < base_parts[i])); then
            return $__EXIT_FAILURE
        fi
    done

    if [[ ${version_parts[3]:-} > ${base_parts[3]:-} ]]; then
        return $__EXIT_SUCCESS
    fi

    return $__EXIT_FAILURE
}

__latest_matching_version() {
    # __latest_matching_version [-p] <specifier>
    #
    # Gives the latest version matching the specifier from a list of versions
    # read on standard input.
    #
    # The versions are expected to follow the *semver* specification. The
    # specifier can be a complete version (major.minor.patch) or omit one or
    # more leading components.
    #
    # Only stable versions are considered by default. But pre-releases (alpha,
    # beta and release candidates) can be considered if the `-p` flag is
    # specified.
    #
    local OPT
    local OPTIND
    local OPTARG
    local -r stable_pattern='^[[:digit:]]+(\.[[:digit:]]+){2}$'
    local -r prereleases_pattern='^[[:digit:]]+(\.[[:digit:]]+){2}(-(a|alpha|b|beta|rc)[[:digit:]])?$'
    local pattern=$stable_pattern

    while getopts ':p' OPT; do
        case $OPT in
            p)
                pattern=$prereleases_pattern
                ;;
            *)
                __print_error "Unknown option '$OPTARG'."
                return 1
                ;;
        esac
    done

    shift $((OPTIND - 1))

    __required "${1:-}" "the version specifier" || return

    local -r specifier=$1
    local -r specifier_pattern=${specifier//./"\."}
    local -i got_input=0
    local version
    local latest_version=""
    local IFS

    shopt -s extglob

    while read -r -t "$TRAVIS_PYTHON_READ_TIMEOUT" version; do
        got_input=1

        if [[ $version =~ $pattern && $version =~ ^${specifier_pattern} ]]; then
            if __is_version_greater "$version" "$latest_version"; then
                latest_version="$version"
            fi
        fi
    done

    if ((!got_input)); then
        __error "no input data" || return
    fi

    if [[ -z $latest_version ]]; then
        __error "no matching version" || return
    fi

    __putsn "$latest_version"
}

__init_file() {
    # __init_file <path>
    #
    # Creates a file located at the specified path.
    #
    # All parent directories are created if needed. If the file already exists,
    # it is overwritten.
    #
    __required "${1:-}" "the path" || return

    local -r path=$1

    mkdir -p "$(dirname "$path")"
    : >|"$path"
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
    __required "$*" "the command" || return

    local -r output_file=$TRAVIS_PYTHON_DIR/$__TRAVIS_PYTHON_SILENT_OUTPUT_FILENAME
    local -r error_file=$TRAVIS_PYTHON_DIR/$__TRAVIS_PYTHON_SILENT_ERROR_FILENAME
    local -i status

    # The files are (re)initialized. This is important in order to clear output
    # from a previously silenced command.
    __init_file "$output_file"
    __init_file "$error_file"

    # Then the stdout and stderr streams are redirected to them.
    "$@" >"$output_file" 2>"$error_file"
    status=$?

    # If the command succeed, the files are removed.
    if ((status == 0)); then
        rm -f "$output_file"
        rm -f "$error_file"
    fi

    return $status
}

__windows_path() {
    # __windows_path <path>
    #
    # Converts a Unix path to Windows flavor.
    #
    __required "${1:-}" "the path" || return

    local -r path=$1
    local converted
    local drive_letter

    # Convert slashes to backslashes
    converted=${path//\//\\}

    if [[ $converted == \\* ]]; then
        # If it is an absolute path...
        if [[ ${converted:2:1} == \\ ]]; then
            # ... and the first component is a single letter, convert it to a
            # drive letter.
            drive_letter=$(tr '[:lower:]' '[:upper:]' <<<"${converted:1:1}")
            converted="$drive_letter:${converted:2}"
        elif [[ ${converted:0:5} == \\tmp\\ ]]; then
            # ... and the first component is the temporary directory, convert it
            # to the Windows user temporary directory path.
            converted="C:\Users\\$USER\AppData\Local\Temp\\${converted:5}"
        fi

    fi

    __putsn "$converted"
}

__latest_git_tag() {
    # __latest_git_tag <directory>
    #
    # Gives the latest tag from the Git repository located at the specified
    # directory.
    #
    __required "${1:-}" "the directory" || return

    local -r directory=$1

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
    __required "${1:-}" "the URL" || return
    __required "${2:-}" "the directory" || return

    local -r url=$1
    local -r directory=$2
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
    python-build --version | __strip_prefix "python-build" | __trim
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
    __required "${1:-}" "the installation directory" || return

    local -r directory=$1
    local -r repo_url="https://github.com/pyenv/pyenv"
    local -r clone_directory="/tmp/pyenv"
    local -r installer="$clone_directory/plugins/python-build/install.sh"
    export PATH

    __print_task "Installing python-build"
    __print_info "requested location" "$directory"
    __update_git_repo $repo_url $clone_directory
    __print_info "installed version" "$(__current_builder_version)"

    PREFIX=$directory $installer

    PATH="$directory/bin:$PATH"
    hash -r

    __print_task_done
}

__available_python_versions_from_builder() {
    # __available_python_versions_from_builder
    #
    # Gives the list of Python versions available from python-build.
    #
    local line

    python-build --definitions | __trim | while read -r -t "$TRAVIS_PYTHON_READ_TIMEOUT" line; do
        shopt -s extglob

        # Add missing pre-release hyphen
        if [[ $line =~ [[:digit:]]([[:alpha:]]) ]]; then
            __putsn "${line/${BASH_REMATCH[1]}/-${BASH_REMATCH[1]}}"
        else
            __putsn "$line"
        fi
    done
}

__available_python_versions_from_chocolatey() {
    # __available_python_versions_from_chocolatey
    #
    # Gives the list of Python versions available from Chocolatey.
    #
    choco list python --exact --all-versions --limit-output | __trim | __strip_prefix "python|"
}

__available_python_versions() {
    # __available_python_versions
    #
    # Gives the list of Python versions available on the current platform.
    #
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
    python --version 2>&1 | __strip_prefix "Python" | __trim
}

setup_travis_python() {
    # setup_travis_python
    #
    # Setups Python tools for Travis CI for installation within specified
    # directory.
    #
    __be_strict

    if [[ -z ${TRAVIS_OS_NAME:-} ]]; then
        __error "the TRAVIS_OS_NAME environment variable must be set and not null" || return
    fi

    __print_banner
    __print_info "version" $TRAVIS_PYTHON_VERSION

    case $TRAVIS_OS_NAME in
        windows)
            # Workaround for https://github.com/chocolatey/choco/issues/1843
            __print_task "Downgrading Chocolatey"
            __print_info "current version" "$(choco --version)"
            __print_info "requested version" "0.10.13"
            __run_silent choco upgrade chocolatey --yes --version 0.10.13 --allow-downgrade
            __print_task_done
            ;;
        linux | osx)
            __install_builder "$TRAVIS_PYTHON_DIR/builder"
            ;;
        *)
            __error "the '$TRAVIS_OS_NAME' platform is not supported" || return
            ;;
    esac
    __be_kind
}

install_python() {
    # install_python [-p] <directory> <specifier>
    #
    # Installs the latest Python version matching the specified one in the
    # specified directory.
    #
    # The specifier can be a complete version (major.minor.patch) or omit one or
    # more leading components.
    #
    # If the `-p` flag is specified, the pre-release versions are considered.
    # Otherwize, only stable versions are searched.
    #
    # When OS is Linux or macOS, python-build is used, on Windows, Chocolatey is used.
    #
    __be_strict

    local OPT
    local OPTIND
    local OPTARG
    local -i prerelease_allowed=0
    local flags=''

    while getopts ':p' OPT; do
        case $OPT in
            p)
                prerelease_allowed=1
                flags+="-p"
                ;;
            *)
                __print_error "Unknown option '$OPTARG'."
                return 1
                ;;
        esac
    done

    shift $((OPTIND - 1))

    __required "${1:-}" "the installation directory" || return
    __required "${2:-}" "the version specifier" || return

    local -r location=$1
    local -r specifier=$2
    local version
    export PATH

    __print_task "Installing Python"
    __print_info "requested version" "$specifier"
    if ((prerelease_allowed)); then
        __print_info "pre-release allowed" "yes"
    else
        __print_info "pre-release allowed" "no"
    fi
    __print_info "requested location" "$location"

    version=$(__available_python_versions | __latest_matching_version $flags "$specifier")

    __print_info "found version" "$version"

    if [[ $TRAVIS_OS_NAME == "windows" ]]; then
        __run_silent choco install python \
            --version="$version" \
            --allow-downgrade \
            --yes \
            --install-arguments="/quiet InstallAllUsers=0 TargetDir=\"$(__windows_path "$location")\"" \
            --override-arguments \
            --apply-install-arguments-to-dependencies

        PATH="$location:$location/Scripts:$PATH"
    else
        CFLAGS='' __run_silent python-build "$version" "$location"
        PATH="$location/bin:$PATH"
    fi

    __print_info "installed version" "$(__current_python_version)"

    hash -r

    __print_task_done

    __be_kind
}

${__SOURCED__:+'return'} # Prevent execution while testing

setup_travis_python # NOT_COVERABLE because of previous line
