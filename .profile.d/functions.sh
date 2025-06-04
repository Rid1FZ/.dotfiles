#!/bin/env bash

# >>> functions >>>
function __fzf {
    fzf --layout=reverse --tmux --border=rounded --height=100% --preview-window 'up,60%,border-rounded,+{2}-5/5' "$@"
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
                "${__cmd} ${1}"
            }
            ;;
    esac
}

function floc {
    local __plocate_prefix __target

    __plocate_prefix="plocate --ignore-case --regex"
    __target="$(__fzf --disabled --keep-right --bind "start:reload:${__plocate_prefix} {q}" --bind "change:reload:sleep 0.1; ${__plocate_prefix} {q} || true" --preview 'preview {}')"

    [[ -z "${__target}" ]] && return 1

    open "${__target}"
}

function ff {
    local __arg __path

    __arg="${1:-.}"
    [[ -d "${__arg}" ]] || return 1

    __path="$(fd -Ha --no-ignore --type symlink --type file --follow --exclude='{.git,.svn,.hg}' ".*" "${__arg}" | __fzf --keep-right --preview="preview {}")"
    [[ -z "${__path}" ]] && return 1

    open "${__path}"
}

function fcd {
    local __arg

    __arg="${1:-.}"
    [[ -d "${__arg}" ]] || return 1

    __dir="$(fd -Ha --no-ignore --type directory --follow --exclude='{.git,.svn,.hg}' ".*" "${__arg}" | __fzf --info=default --keep-right --preview="preview {}")"
    [[ -z "${__dir}" ]] && return 1

    builtin cd -- "${__dir}" || return 1
}

function frg {
    local __rg_prefix

    __rg_prefix="rg --no-config --column --line-number --no-heading --hidden --follow --color=always --colors=path:fg:blue --smart-case --glob='!{.git,.svn,.hg}'"
    __fzf --disabled \
        --bind "start:reload:${__rg_prefix} {q} ${1:-.}" \
        --bind "change:reload:sleep 0.1; ${__rg_prefix} {q} || true" \
        --delimiter : \
        --preview 'bat --color=always {1} --highlight-line {2} --theme="Catppuccin Macchiato"' \
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
