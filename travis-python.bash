# http://redsymbol.net/articles/unofficial-bash-strict-mode/
# set -euo pipefail
# IFS=$'\n\t'

TRAVIS_PYTHON_VERSION="0.1.0"

print_info() {
    # print_info <message>
    #
    # Prints the given message to the standard ouput stream in cyan.
    #
    local message=${1:?the message must be specified}

    if [[ -t 1 && $(tput colors) ]]; then
        message="\033[0;33m$message\033[0m"
    fi

    echo -e "$message"
}

print_success() {
    # print_success <message>
    #
    # Prints the given message to the standard ouput stream in green.
    #
    local message=${1:?the message must be specified}

    if [[ -t 1 && $(tput colors) ]]; then
        message="\033[0;32m$message\033[0m"
    fi

    echo -e "$message"
}

print_error() {
    # print_error <message>
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

trim() {
    # trim <string>
    #
    # Trims leading and trailing whitespace characters from given string.
    #
    local string=${1?the string must be specified}

    shopt -s extglob
    string=${string##+([[:space:]])}
    string=${string%%+([[:space:]])}

    echo "$string"
}

windows_path() {
    # windows_path <path>
    #
    # Converts a Unix path to Windows flavor.
    #
    local -r path=${1:?the path must be specified}
    local converted
    local parts

    # Convert slashes to backslashes
    converted=${path//\//\\}

    if [[ $converted == \\* ]]; then
        # If it is an absolute path, convert the first component to a drive letter
        IFS=\\ read -ra parts <<<"$converted"
        unset "parts[0]"
        parts[1]="${parts[1]^}:"

        OLDIFS=$IFS
        IFS=\\
        converted=${parts[*]}
        IFS=$OLDIFS
    fi

    echo "$converted"
}

latest_matching_version() {
    # latest_matching_version <specifier> <version>...
    #
    # Gives the latest version matching the specifier from a list of versions.
    #
    # The versions are expected to follow the *semver* specification. The
    # specifier can be a complete version (major.minor.patch) or omit one or
    # more leading components.
    #
    local -r specifier=${1:?the specifier must be specified}
    local -r specifier_pattern=${specifier//./"\."}
    shift
    local versions=("${@:?the versions must be specified}")
    local found_version=""

    if ((${#versions} == 0)); then
        echo "the versions must not be empty" >&2
        return 1
    fi

    #shellcheck disable=SC2207
    IFS=$'\n' versions=($(sort -V <<<"${versions[*]}"))

    shopt -s extglob

    for version in "${versions[@]}"; do
        # if [[ $version == ${specifier}*(.+([0-9])) ]]; then
        if [[ $version =~ ^${specifier_pattern}(\.[:digit:]+)* ]]; then
            found_version="$version"
        fi
    done

    [[ -n $found_version ]] || return

    echo "$found_version"
}

latest_git_tag() {
    # latest_git_tag <directory>
    #
    # Gives the latest tag from the Git repsitory located at the specified
    # directory.
    #
    local -r directory=${1:?the directory must be specified}

    git -C "$directory" describe --abbrev=0 --tags
}

update_git_repo() {
    # update_git_repo <URL> <directory>
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

    latest_tag=$(latest_git_tag "$directory")
    git -C "$directory" checkout "$latest_tag" --detach --quiet
}

current_pyenv_version() {
    # current_pyenv_version
    #
    # Gives the current version of Pyenv.
    #
    local version

    version=$(pyenv --version)
    version="${version#'pyenv'}"
    version=$(trim "$version")

    echo "$version"
}

install_pyenv() {
    # install_pyenv <directory>
    #
    # Installs pyenv to the specified directory.
    #
    # The pyenv distribution is cloned from its Git repository and the latest
    # release is fetched.
    #
    # The `PATH` is updated to include the pyenv distribution and the shell
    # commands hash table is reset.
    #
    # The `PYENV_ROOT` environment variable is set to LOCATION.
    #
    local directory=${1:?the installation directory must be specified}
    local -r repo_url="https://github.com/pyenv/pyenv"
    export PYENV_ROOT
    export PATH

    print_info "Installing latest Pyenv to $directory..."
    update_git_repo $repo_url "$directory" || return

    PYENV_ROOT=$directory
    PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"
    hash -r

    print_success "Installed Pyenv $(current_pyenv_version)."
}

available_python_versions_with_pyenv() {
    # available_python_versions_with_pyenv
    #
    # Gives the list of Python versions available via pyenv.
    #
    local versions
    local versions=()

    while IFS='' read -r version; do
        version=$(trim "$version")

        if [[ -n $version ]]; then
            versions=("${versions[@]}" "$version")
        fi
    done < <(pyenv install --list)

    echo "${versions[@]}"
}

available_python_versions_with_chocolatey() {
    # available_python_versions_with_chocolatey
    #
    # Gives the list of Python versions available via Chocolatey.
    #
    local output
    local version
    local versions=()

    output=$(choco list python --exact --all-versions --limit-output)

    while read -r version; do
        version=$(trim "$version")
        version="${version#'python|'}"

        if [[ -n $version ]]; then
            versions=("${versions[@]}" "$version")
        fi
    done <<<"$output"

    echo "${versions[@]}"
}

current_python_version() {
    # current_python_version
    #
    # Gives the current version of Python.
    #
    local version

    version=$(python --version 2>&1)
    version="${version#'Python'}"
    version=$(trim "$version")

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
        available_versions=($(available_python_versions_with_chocolatey))
    else
        # shellcheck disable=SC2207
        available_versions=($(available_python_versions_with_pyenv))
    fi

    version=$(latest_matching_version "$specifier" "${available_versions[@]}")

    if [[ -z $version ]]; then
        print_error "No Python version found matching $specifier"
        return 1
    fi

    print_info "Installing Python $version..."

    if [[ $TRAVIS_OS_NAME == "windows" ]]; then
        choco install python \
            --version="$version" \
            --yes \
            --install-arguments="/quiet InstallAllUsers=0 TargetDir=\"$(windows_path "$location")\"" \
            --override-arguments \
            --apply-install-arguments-to-dependencies

        PATH="$location:$location/Scripts:$PATH"
        hash -r
    else
        pyenv install --skip-existing "$version" &>/dev/null
        pyenv global "$version"
        pyenv rehash
    fi

    print_success "Installed Python $(current_python_version)."
}

__travis_python_setup() {
    # __travis_python_setup
    #
    # Setups Python tools for Travis CI for installation within specified
    # directory.
    #
    : "${TRAVIS_OS_NAME:?must be set and not null}"

    print_info "travis-python $TRAVIS_PYTHON_VERSION"

    case ${TRAVIS_OS_NAME} in
        windows)
            # Workaround for https://github.com/chocolatey/choco/issues/1843
            choco upgrade chocolatey --yes --version 0.10.13 --allow-downgrade
            print_success "Installed Chocolatey $(choco --version)."
            ;;
        linux | osx)
            install_pyenv "$HOME/Pyenv"
            ;;
        *)
            print_error "The '$TRAVIS_OS_NAME' platform is not supported."
            return 1
            ;;
    esac

    print_success "Python tools for Travis CI loaded."
}

${__SOURCED__:+'return'} # Prevent execution while testing

__travis_python_setup
