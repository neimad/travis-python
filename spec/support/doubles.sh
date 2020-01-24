# shellcheck shell=bash

# SPY_DIR
#
# The location of the spy reports.
#
export SPY_DIR="$SHELLSPEC_TMPBASE/spy"
export SPY_CALLS_FILE=
mkdir -p "$SPY_DIR"

dummy() {
    # dummy <program>
    #
    # Creates a dummy for the specified program.
    # It outputs nothing and returns 0.
    local -r program=${1:?the program must be specified}

    stub "$program"
}

stub() {
    # stub <program> [-o <output>] [-e <error>] [-s <status>]
    #
    # Creates a stub for the specified program.
    # If output is specified, the stub outputs it to stdout.
    # If error is specified, the stub outputs it to stderr.
    # If status is specified, the stub returns it, 0 otherwize.
    #
    local -r program=${1:?the program must be specified}
    shift
    local OPT
    local OPTIND
    local -i has_output=0
    local output=
    local -i has_error=0
    local error=
    local -i status=0
    local code

    while getopts "o:e:s:" OPT; do
        case "$OPT" in
            o)
                has_output=1
                output="$OPTARG"
                ;;
            e)
                has_error=1
                error="$OPTARG"
                ;;
            s) status="$OPTARG" ;;
            *) return 1 ;;
        esac
    done

    code="$program() {"

    if (( has_output )); then
        code="$code echo '$output';"
    fi

    if (( has_error )); then
        code="$code echo '$error' >&2;"
    fi

    code="$code return $status; }"

    eval "$code"
}

spy() {
    # spy <program>
    #
    # Spy the specified program.
    # The program is replaced by a dummy. Every call is registered and can be
    # found using `spy_check()`.
    #
    local -r program=${1:?the program must be specified}
    export SPY_CALLS_FILE="$SPY_DIR/$SHELLSPEC_EXAMPLE_ID.log"

    shellspec_puts '' >"$SPY_CALLS_FILE"

    eval "$program() {
        local IFS=' '
        local command_line

        command_line=\"$program\"

        if (( \$# > 0 )); then
            command_line=\"\$command_line \$*\"
        fi

        shellspec_putsn \"\$command_line\" >>$SPY_CALLS_FILE
    }"
}

spy_check() {
    # spy_check <command_line>
    #
    # Checks if the specified command line has been called.
    # The command must be spied using `spy()`.
    #
    local -r command_line=${1:?the command line must be specified}

    if [[ ! -f "$SPY_CALLS_FILE" ]]; then
        return 1
    fi

    grep -q "$command_line" "$SPY_CALLS_FILE"
}

spy_dump() {
    # spy_dump
    #
    # Dumps the calls made to the spied commands.
    #
    local -r content=$([[ -f $SPY_CALLS_FILE ]] && cat "$SPY_CALLS_FILE")

    shellspec_putsn "
Spy Report
----------
$content"
}

# 'command' subject
shellspec_syntax_alias 'shellspec_subject_command' 'shellspec_subject_value'

# 'be called' matcher
shellspec_syntax 'shellspec_matcher_be_called'
shellspec_syntax_compound 'shellspec_matcher_be'

shellspec_matcher_be_called() {
    shellspec_matcher__match() {
        [ "${SHELLSPEC_SUBJECT+x}" ] || return 1
        spy_check "$SHELLSPEC_SUBJECT"
    }

    shellspec_matcher__failure_message() {
        shellspec_putsn "expected command $1 to be called"
        spy_dump
    }

    shellspec_matcher__failure_message_when_negated() {
        shellspec_putsn "expected command $1 to not be called"
        spy_dump
    }

    shellspec_syntax_param count [ $# -eq 0 ] || return 0
    shellspec_matcher_do_match "$@"
}
