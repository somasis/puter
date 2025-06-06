# shellcheck shell=bash

: "${XDG_CACHE_HOME:=${HOME}/.cache}"
set -euo pipefail

usage() {
    # shellcheck disable=SC2059
    [[ $# -eq 0 ]] || printf "$@" >&2
    cat >&2 <<EOF
usage: ${0##*/} [-qv] file...

Losslessly optimize/transparently compress a given file, in-place, using the
appropriate tool for its format.

Supported formats:
    audio/flac
    image/jpeg
    image/png

options:
    -q              decrement verbosity level
    -v              increment verbosity level
EOF
    exit 69
}

cache="${XDG_CACHE_HOME}"/optimize/optimized.sha512sum.hashes

verbosity=0

while getopts :qv opt; do
    case "${opt}" in
        q) verbosity=$((verbosity - 1)) ;;
        v) verbosity=$((verbosity + 1)) ;;
        *) usage "unknown option -- %s\n" "${opt}" ;;
    esac
done
shift $((OPTIND - 1))

if [[ $# -eq 0 ]]; then usage; fi

mkdir -p "${XDG_CACHE_HOME}"/optimize
touch "${cache}"

files_total="$#"
files_optimized=0
files_unoptimized=0

edo() {
    [[ ${verbosity} -gt 2 ]] && printf '$ %s\n' "$*" >&2
    "$@"
}

for file; do
    if ! [[ -e ${file} ]]; then
        printf 'error: file %s does not exist\n' "${file@Q}" >&2
        exit 127
    fi

    file_size_before=$(stat -c '%s' "${file}")
    file_hash="${file}"$'\n'"${file_size_before}"$'\n'"$(realpath "${file}")"
    file_hash=$(sha512sum <<<"${file_hash}")
    file_hash=${file_hash:0:128}

    if grep -Fxq "${file_hash}" "${cache}"; then
        [[ ${verbosity} -gt 1 ]] && printf 'skipping file "%s" (already optimized in the past, matched hash)\n' "${file}" >&2
        continue
    fi

    file_type=$(file -L -b --mime-type "${file}")

    # file_size_before_pretty=$(du -h "${file}" | cut -f1)

    file_optimized=false
    write_file_to_cache=true

    case "${file_type}" in
        audio/flac)
            # output="${file%.*}.optimized.${file##*.}"
            if edo flac --best --keep-foreign-metadata-if-present --silent "${file}"; then
                file_optimized=true
            else
                files_unoptimized=$((files_unoptimized + 1))
            fi
            ;;

        image/jpeg)
            if edo jpegoptim --quiet --workers="$(nproc)" --preserve "${file}"; then
                file_optimized=true
            else
                files_unoptimized=$((files_unoptimized + 1))
            fi
            ;;
        image/png)
            if
                ! edo oxipng --quiet --preserve -o max "${file}" \
                    && ! edo oxipng --quiet --preserve -o max -Z "${file}" \
                    && ! edo oxipng --quiet --preserve -o max -Z "${file}" \
                    && ! edo optipng -quiet -preserve -o5 "${file}"
            then
                files_unoptimized=$((files_unoptimized + 1))
            else
                file_optimized=true
            fi
            ;;
        *)
            printf 'warning: skipping file "%s" (unsupported type: %s)\n' "${file}" "${file_type}" >&2
            files_unoptimized=$((files_unoptimized + 1))
            write_file_to_cache=false
            ;;
    esac

    if [[ ${write_file_to_cache} == true ]]; then
        printf '%s\n' "${file_hash}" >>"${cache}"
    fi

    if [[ ${file_optimized} == true ]]; then
        files_optimized=$((files_optimized + 1))
    fi

    file_size_after=$(stat -c '%s' "${file}")
    # file_size_after_pretty=$(du -h "${file}" | cut -f1)

    if [[ ${verbosity} -ge 0 ]] && [[ ${file_size_before} -ne ${file_size_after} ]]; then
        if [[ ${files_total} -gt 1 ]]; then
            printf '%s: %s -> %s\n' "${file}" "${file_size_before}" "${file_size_after}" >&2
        else
            printf '%s -> %s\n' "${file_size_before}" "${file_size_after}" >&2
        fi
    fi
done

if [[ ${files_total} -gt 1 ]]; then
    [[ ${verbosity} -gt 1 ]] && printf 'optimized %i file(s) of %i total\n' "${files_optimized}" "${files_total}" >&2
    if [[ ${files_unoptimized} -gt 0 ]]; then
        exit 1
    fi
fi
