#!/bin/env bash

# >>> functions >>>
function __fzf {
    command fzf --layout=reverse --tmux --border=rounded --height=100% --preview-window 'up,60%,border-rounded,+{2}-5/5' "$@"
}

function open {
    local parsed
    parsed=$(getopt -o 'h' --long 'help' -n 'open' -- "$@") || return 1
    eval set -- "${parsed}"

    while true; do
        case "$1" in
        -h | --help)
            echo "Usage: open <file|directory>"
            return 0
            ;;
        --)
            shift
            break
            ;;
        esac
    done

    if [[ $# -eq 0 ]]; then
        echo -e "[error]: no argument given" >&2
        return 1
    elif [[ $# -gt 1 ]]; then
        echo -e "[error]: too many arguments (expected 1, got $#)" >&2
        return 1
    fi

    case "$(command file -b --mime-type --dereference "${1}")" in
    inode/directory)
        builtin cd -- "${1}" || return 1
        ;;
    text/* | application/javascript | application/toml | application/x-shellscript | application/x-zerosize)
        command "${EDITOR}" "${1}"
        ;;
    *)
        command xdg-open "${1}" &>/dev/null || {
            local cmd
            echo -e "[error]: xdg-open failed\n"
            printf "enter command to open file: "
            read -r cmd
            command ${cmd} "${1}"
        }
        ;;
    esac
}

function ff {
    local parsed
    parsed=$(getopt -o 'h' --long 'help' -n 'ff' -- "$@") || return 1
    eval set -- "${parsed}"

    while true; do
        case "$1" in
        -h | --help)
            echo "Usage: ff [directory]"
            return 0
            ;;
        --)
            shift
            break
            ;;
        esac
    done

    if [[ $# -gt 1 ]]; then
        echo -e "[error]: too many arguments (expected at most 1, got $#)" >&2
        return 1
    fi

    local arg="${1:-.}"
    [[ -d "${arg}" ]] || {
        echo -e "[error]: '${arg}' is not a directory" >&2
        return 1
    }

    local input_path
    input_path="$(command fd -Ha --no-ignore --type symlink --type file --follow --exclude='{.git,.svn,.hg}' ".*" "${arg}" | __fzf --keep-right --preview="preview {}")"
    [[ -z "${input_path}" ]] && return 1

    open "${input_path}"
}

function fcd {
    local parsed
    parsed=$(getopt -o 'h' --long 'help' -n 'fcd' -- "$@") || return 1
    eval set -- "${parsed}"

    while true; do
        case "$1" in
        -h | --help)
            echo "Usage: fcd [directory]"
            return 0
            ;;
        --)
            shift
            break
            ;;
        esac
    done

    if [[ $# -gt 1 ]]; then
        echo -e "[error]: too many arguments (expected at most 1, got $#)" >&2
        return 1
    fi

    local arg="${1:-.}"
    [[ -d "${arg}" ]] || {
        echo -e "[error]: '${arg}' is not a directory" >&2
        return 1
    }

    local input_dir
    input_dir="$(command fd -Ha --no-ignore --type directory --follow --exclude='{.git,.svn,.hg}' ".*" "${arg}" | __fzf --info=default --keep-right --preview="preview {}")"
    [[ -z "${input_dir}" ]] && return 1
    builtin cd -- "${input_dir}" || return 1
}

function frg {
    local parsed
    parsed=$(getopt -o 'h' --long 'help' -n 'frg' -- "$@") || return 1
    eval set -- "${parsed}"

    while true; do
        case "$1" in
        -h | --help)
            echo "Usage: frg [directory]"
            return 0
            ;;
        --)
            shift
            break
            ;;
        esac
    done

    if [[ $# -gt 1 ]]; then
        echo -e "[error]: too many arguments (expected at most 1, got $#)" >&2
        return 1
    fi

    local rg_prefix
    rg_prefix="command rg --no-config --column --line-number --no-heading --hidden --follow --color=always --colors=path:fg:blue --smart-case --glob='!{.git,.svn,.hg}'"
    __fzf --disabled \
        --bind "start:reload:${rg_prefix} {q} ${1:-.}" \
        --bind "change:reload:sleep 0.1; ${rg_prefix} {q} || true" \
        --delimiter : \
        --preview 'bat --color=always {1} --highlight-line {2} --theme="Catppuccin Macchiato"' \
        --bind 'enter:become(nvim {1} +{2})'
}

function rm {
    local extra_flags files nargs

    extra_flags=()
    files=()
    nargs="$#"

    while [[ $# -gt 0 ]]; do
        case "$1" in
        --)
            shift
            files+=("$@")
            break
            ;;
        --*)
            extra_flags+=("$1")
            shift
            ;;
        -*)
            local opts="${1#-}" fwd=""
            shift
            while [[ -n "${opts}" ]]; do
                fwd+="${opts:0:1}"
                opts="${opts:1}"
            done
            [[ -n "${fwd}" ]] && extra_flags+=("-${fwd}")
            ;;
        *)
            files+=("$1")
            shift
            ;;
        esac
    done

    local to_trash=()
    for arg in "${files[@]}"; do
        if [[ -L "${arg}" && ! -e "${arg}" ]]; then
            unlink "${arg}"
        else
            to_trash+=("${arg}")
        fi
    done

    if (("${nargs}" == 0)) || (("${#to_trash[@]}" != 0)) || (("${#extra_flags[@]}" != 0)); then
        command trash-put "${extra_flags[@]}" "${to_trash[@]}"
    fi
}

function tree {
    local show_all use_jq extra_args

    show_all=false
    use_jq=false
    extra_args=()

    while [[ $# -gt 0 ]]; do
        case "$1" in
        --all)
            show_all=true
            shift
            ;;
        --json)
            use_jq=true
            shift
            ;;
        --)
            shift
            extra_args+=("$@")
            break
            ;;
        --*)
            extra_args+=("$1")
            shift
            ;;
        -*)
            local opts="${1#-}" fwd=""
            shift
            while [[ -n "${opts}" ]]; do
                case "${opts:0:1}" in
                a) show_all=true ;;
                J) use_jq=true ;;
                *) fwd+="${opts:0:1}" ;;
                esac
                opts="${opts:1}"
            done
            [[ -n "${fwd}" ]] && extra_args+=("-${fwd}")
            ;;
        *)
            extra_args+=("$1")
            shift
            ;;
        esac
    done

    local tree_args=(--dirsfirst -F -I '.git')
    [[ "${show_all}" == true ]] && tree_args+=(-a) || tree_args+=(--gitignore)
    [[ "${use_jq}" == true ]] && tree_args+=(-J)

    if [[ "$use_jq" == true ]]; then
        command tree "${tree_args[@]}" "${extra_args[@]}" | command jq --compact-output --monochrome-output
    else
        command tree "${tree_args[@]}" "${extra_args[@]}"
    fi
}
# <<< functions <<<
