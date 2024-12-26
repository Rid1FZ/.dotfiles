#!/bin/env bash

# >>> functions >>>
function __fzf {
    (
        FZF_DEFAULT_OPTS=" \
            ${FZF_DEFAULT_OPTS} \
            --layout=reverse \
            --tmux \
            --ansi \
            --border=rounded"

        fzf "$@"
    )
}

function open {
    case "$(file -b --mime-type --dereference "${1}")" in
        inode/directory)
            builtin cd -- "${1}" || return 1
            ;;
        text/* | application/javascript | application/toml | application/x-shellscript | application/x-zerosize)
            "${EDITOR}" "${1}"
            ;;
        *)
            xdg-open "$1" &>/dev/null || {
                local __cmd
                echo -e "\033[0;31m[error]\033[0m: xdg-open failed\n"
                printf "enter command to open file: "
                read -r __cmd
                exec "${__cmd} ${1}"
            }
            ;;
    esac
}

function floc {
    local __plocate_prefix __target

    echo "updating plocate database. password may require..."
    sudo updatedb

    __plocate_prefix="plocate --ignore-case --regex"
    __target="$(__fzf --disabled --keep-right --bind "start:reload:${__plocate_prefix} {q}" --bind "change:reload:sleep 0.1; ${__plocate_prefix} {q} || true" --preview 'preview {}' --height=100% --preview-window 'right,60%,border-left')"

    [[ -z "${__target}" ]] && return 1

    open "${__target}"
}

function ff {
    local __arg __path

    __arg="${1:-.}"
    [[ -d "${__arg}" ]] || return 1

    __path="$(fd -Ha --no-ignore --type symlink --type file --follow --exclude='{.git,.svn,.hg}' ".*" "${__arg}" | __fzf --keep-right --height=100% --preview="preview {}" --preview-window 'right,60%,border-left')"
    [[ -z "${__path}" ]] && return 1

    open "${__path}"
}

function fcd {
    local __arg

    __arg="${1:-.}"
    [[ -d "${__arg}" ]] || return 1

    __dir="$(fd -Ha --no-ignore --type directory --follow --exclude='{.git,.svn,.hg}' ".*" "${__arg}" | __fzf --layout=reverse --border=rounded --info=default --keep-right --height=100% --preview="preview {}" --preview-window 'top,60%,border-bottom')"
    [[ -z "${__dir}" ]] && return 1

    builtin cd -- "${__dir}"
}

function frg {
    local __rg_prefix

    __rg_prefix="rg --no-config --column --line-number --no-heading --hidden --follow --color=always --colors=path:fg:blue --smart-case --glob='!{.git,.svn,.hg}'"
    __fzf --disabled \
        --bind "start:reload:${__rg_prefix} {q} ${1:-.}" \
        --bind "change:reload:sleep 0.1; ${__rg_prefix} {q} || true" \
        --delimiter : \
        --preview 'bat --color=always {1} --highlight-line {2} --theme="Catppuccin Macchiato"' \
        --height=100% \
        --preview-window 'up,60%,border-bottom,+{2}-5/5' \
        --bind 'enter:become(nvim {1} +{2})'
}

function rm {
    local __to_trash __arg

    (("$#" == 0)) && echo -e "\033[0;31m[error]\033[0m: please specify file to remove..." >&2
    __to_trash=()

    for __arg in "$@"; do
        if [[ -L "${__arg}" ]]; then
            unlink "${__arg}"
        else
            __to_trash+=("${__arg}")
        fi
    done

    if (("${#__to_trash[@]}" != 0)); then
        trash-put "${__to_trash[@]}"
    else
        return 0
    fi
}

function mkfile {
    local __file __parent_dir

    (("$#" == 0)) && { echo -e "\033[0;31m[error]\033[0m: please specify at-least one filename..." >&2 && return 1; }

    for __file in "$@"; do
        __parent_dir="$(realpath --canonicalize-missing --no-symlinks "$(dirname "${__file}")")"
        if ! { mkdir -p "${__parent_dir}" 2>/dev/null && touch "${__file}" 2>/dev/null; }; then
            echo -e "\033[0;31m[error]\033[0m: could not create file ${__file}..." >&2
            continue
        fi
    done
}

# for vterm inside emacs
function vterm_printf {
    if [ -n "$TMUX" ] && ([ "${TERM%%-*}" = "tmux" ] || [ "${TERM%%-*}" = "screen" ]); then
        # Tell tmux to pass the escape sequences through
        printf "\ePtmux;\e\e]%s\007\e\\" "$1"
    elif [ "${TERM%%-*}" = "screen" ]; then
        # GNU screen (screen, screen-256color, screen-256color-bce)
        printf "\eP\e]%s\007\e\\" "$1"
    else
        printf "\e]%s\e\\" "$1"
    fi
}
# <<< functions <<<
