# shellcheck shell=bash
# usage: edo <command arguments...>
# run a command noisly, printing a message like
# $ printf '%s\n' hello world
# before running it, quoting arguments as necessary (which makes them
# better for copy-paste usage) and generally is more readable than
# set -x (in my opinion).
#
# This function is an old habit that I needed to keep around back from
# when I wrote a lot of stuff in Exherbo Linux's package format,
# exheres-0, which iirc, got some of its functions from Gentoo's portage
# package formats. I rewrote it a few times over the years and this is
# the version of it I currently use.
edo() {
    local arg string
    string="$"
    for arg; do
        if [[ ${arg@Q} == "'$arg'" ]] && ! [[ ${arg} =~ [[:blank:]] ]]; then
            string+=" $arg"
        else
            string+=" ${arg@Q}"
        fi
    done

    printf '%s\n' "$string" >&2 || :
    "$@"
}

# usage: ido <command arguments...>
# Interactive do; run a command noisly, but ask before doing so.
ido() {
    local reply

    read -r -n1 -p "run \`$(condquote "$@")\`? [Y/n] " reply >&2
    case "${reply}" in
        [Yy] | '')
            printf '\n' >&2
            ;;
        *)
            return 1
            ;;
    esac

    edo "$@"
}

# Given arguments, quote tokens only if the shell would require them to be.
condquote() {
    local arg string
    string=
    for arg; do
        if [[ ${arg@Q} == "'$arg'" ]] && ! [[ ${arg} =~ [[:blank:]] ]]; then
            string+=" $arg"
        else
            string+=" ${arg@Q}"
        fi
    done

    printf '%s\n' "${string}"
}

# usage: usage [<printf(1) arguments>]
usage() {
    # shellcheck disable=SC2059
    [[ $# -eq 0 ]] || printf "$@" >&2

    cat >&2 <<EOF
usage: ${0##*/} <show>

Description of the script being ran, which wraps nice and neatly at
column 72 ideally, and explains to the user the general idea of what
this command does.

Further explanation follows, according to <http://docopt.org/>, for
the most part.

options:
    <bar>

environment variables:
    \$EMAIL${EMAIL:+ (current: $EMAIL)}
        The email which will be used to send the message.

see also: related programs, perhaps.

Kylie McClain <kylie@somas.is>
EOF
    [[ $# -eq 0 ]] || exit 1
    exit 64 # EX_USAGE
}

and() {
    tee >("$@" >&2)
}

peek() { tee /dev/stderr; }
