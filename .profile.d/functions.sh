#!/bin/env bash

# >>> functions >>>
function __fzf {
    fzf --layout=reverse --tmux --border=rounded --height=100% --preview-window 'up,60%,border-rounded,+{2}-5/5' "$@"
}

function open {
    [[ -z "${1}" ]] && {
        echo -e "\033[0;31m[error]\033[0m: no argument given" >&2
        return 1
    }

    case "$(file -b --mime-type --dereference "${1}")" in
    inode/directory)
        builtin cd -- "${1}" || return 1
        ;;
    text/* | application/javascript | application/toml | application/x-shellscript | application/x-zerosize)
        "${EDITOR}" "${1}"
        ;;
    *)
        xdg-open "$1" &>/dev/null || {
            local cmd

            echo -e "\033[0;31m[error]\033[0m: xdg-open failed\n"
            printf "enter command to open file: "
            read -r cmd

            ${cmd} "${1}"
        }
        ;;
    esac
}

function ff {
    local arg input_path

    arg="${1:-.}"
    [[ -d "${arg}" ]] || {
        echo -e "\033[0;31m[error]\033[0m: '${arg}' is not a directory" >&2
        return 1
    }

    input_path="$(fd -Ha --no-ignore --type symlink --type file --follow --exclude='{.git,.svn,.hg}' ".*" "${arg}" | __fzf --keep-right --preview="preview {}")"
    [[ -z "${input_path}" ]] && return 1

    open "${input_path}"
}

function fcd {
    local arg input_dir

    arg="${1:-.}"
    [[ -d "${arg}" ]] || {
        echo -e "\033[0;31m[error]\033[0m: '${arg}' is not a directory" >&2
        return 1
    }

    input_dir="$(fd -Ha --no-ignore --type directory --follow --exclude='{.git,.svn,.hg}' ".*" "${arg}" | __fzf --info=default --keep-right --preview="preview {}")"
    [[ -z "${input_dir}" ]] && return 1

    builtin cd -- "${input_dir}" || return 1
}

function frg {
    local rg_prefix

    rg_prefix="rg --no-config --column --line-number --no-heading --hidden --follow --color=always --colors=path:fg:blue --smart-case --glob='!{.git,.svn,.hg}'"
    __fzf --disabled \
        --bind "start:reload:${rg_prefix} {q} ${1:-.}" \
        --bind "change:reload:sleep 0.1; ${rg_prefix} {q} || true" \
        --delimiter : \
        --preview 'bat --color=always {1} --highlight-line {2} --theme="Catppuccin Macchiato"' \
        --bind 'enter:become(nvim {1} +{2})'
}

function rm {
    local to_trash arg

    (("$#" == 0)) && {
        echo -e "\033[0;31m[error]\033[0m: please specify file to remove..." >&2
        return 1
    }
    to_trash=()

    for arg in "$@"; do
        if [[ -L "${arg}" ]]; then
            unlink "${arg}"
        else
            to_trash+=("${arg}")
        fi
    done

    if (("${#to_trash[@]}" != 0)); then
        trash-put "${to_trash[@]}"
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
