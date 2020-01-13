# SPDX-License-Identifier: GPL-3.0-or-later

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
# set -euo pipefail
# IFS=$'\n\t'

TRAVIS_PYTHON_VERSION="0.1.2"
TRAVIS_PYTHON_DIR="$HOME/travis-python"

__print_info() {
    # __print_info <message>
    #
    # Prints the given message to the standard ouput stream in cyan.
    #
    local message=${1:?the message must be specified}

    if [[ -t 1 && $(tput colors) ]]; then
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

    if [[ -t 1 && $(tput colors) ]]; then
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

    if [[ -t 1 && $(tput colors) ]]; then
        message="\033[0;31m$message\033[0m"
    fi

    echo -e "$message" >&2
    return 1
}

__trim() {
    # __trim <string>
    #
    # Trims leading and trailing whitespace characters from given string.
    #
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
    local -r path=${1:?the path must be specified}
    local converted
    local drive_letter

    # Convert slashes to backslashes
    converted=${path//\//\\}

    if [[ $converted == \\* ]]; then
        # If it is an absolute path, convert the first component to a drive letter
        drive_letter=$(tr '[:lower:]' '[:upper:]' <<<"${converted:1:1}" )
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
    # Only stable versions are considered ()
    #
    local -r specifier=${1:?the specifier must be specified}
    local -r specifier_pattern=${specifier//./"\."}
    shift
    local versions=("${@:?the versions must be specified}")
    local found_version=""
    local IFS

    if ((${#versions} == 0)); then
        echo "the versions must not be empty" >&2
        return 1
    fi

    #shellcheck disable=SC2207
    IFS=$'\n' versions=($(sort -V <<<"${versions[*]}"))

    shopt -s extglob

    for version in "${versions[@]}"; do
        if [[ $version =~ ^${specifier_pattern}(\.[[:digit:]]+)*$ ]]; then
            found_version="$version"
        fi
    done

    [[ -n $found_version ]] || return

    echo "$found_version"
}

__latest_git_tag() {
    # __latest_git_tag <directory>
    #
    # Gives the latest tag from the Git repsitory located at the specified
    # directory.
    #
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
    local -r url=${1:?the URL must be specified}
    local -r directory=${2:?the directory must be specified}
    local latest_tag

    if [[ ! -d $directory ]]; then
        git clone "$url" "$directory" --quiet
    else
        git -C "$directory" fetch
    fi

    latest_tag=$(__latest_git_tag "$directory")
    git -C "$directory" checkout "$latest_tag" --detach --quiet
}

__current_builder_version() {
    # __current_builder_version
    #
    # Gives the current version of python-build.
    #
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

__available_python_versions_with_builder() {
    # __available_python_versions_with_builder
    #
    # Gives the list of Python versions available via python-build.
    #
    local versions
    local versions=()
    local IFS

    while IFS='' read -r version; do
        version=$(__trim "$version")

        if [[ -n $version ]]; then
            versions=("${versions[@]}" "$version")
        fi
    done < <(python-build --definitions)

    echo "${versions[@]}"
}

__available_python_versions_with_chocolatey() {
    # __available_python_versions_with_chocolatey
    #
    # Gives the list of Python versions available via Chocolatey.
    #
    local output
    local version
    local versions=()

    output=$(choco list python --exact --all-versions --limit-output)

    while read -r version; do
        version=$(__trim "$version")
        version="${version#'python|'}"

        if [[ -n $version ]]; then
            versions=("${versions[@]}" "$version")
        fi
    done <<<"$output"

    echo "${versions[@]}"
}

__current_python_version() {
    # __current_python_version
    #
    # Gives the current version of Python.
    #
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
    local -r location=${1:?the installation directory must be specified}
    local -r specifier=${2:?the specifier must be specified}
    local -a available_versions
    local version
    export PATH

    if [[ $TRAVIS_OS_NAME == "windows" ]]; then
        # shellcheck disable=SC2207
        available_versions=($(__available_python_versions_with_chocolatey))
    else
        # shellcheck disable=SC2207
        available_versions=($(__available_python_versions_with_builder))
    fi

    version=$(__latest_matching_version "$specifier" "${available_versions[@]}")

    if [[ -z $version ]]; then
        __print_error "No Python version found matching $specifier"
        return 1
    fi

    __print_info "Installing Python $version..."

    if [[ $TRAVIS_OS_NAME == "windows" ]]; then
        choco install python \
            --version="$version" \
            --yes \
            --install-arguments="/quiet InstallAllUsers=0 TargetDir=\"$(__windows_path "$location")\"" \
            --override-arguments \
            --apply-install-arguments-to-dependencies

        PATH="$location:$location/Scripts:$PATH"
    else
        python-build "$version" "$location" &>/dev/null
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
    : "${TRAVIS_OS_NAME:?must be set and not null}"

    __print_info "travis-python $TRAVIS_PYTHON_VERSION"

    case ${TRAVIS_OS_NAME} in
        windows)
            # Workaround for https://github.com/chocolatey/choco/issues/1843
            choco upgrade chocolatey --yes --version 0.10.13 --allow-downgrade
            __print_success "Installed Chocolatey $(choco --version)."
            ;;
        linux | osx)
            __install_builder "$TRAVIS_PYTHON_DIR/builder"
            ;;
        *)
            __print_error "The '$TRAVIS_OS_NAME' platform is not supported."
            return 1
            ;;
    esac

    __print_success "Python tools for Travis CI loaded."
}

${__SOURCED__:+'return'} # Prevent execution while testing

__travis_python_setup
