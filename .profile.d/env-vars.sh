#!/bin/env bash

function splitvar {
    # It will reverese the order for later use with `prepend_value` function
    local string="$1"
    local separator="$2"

    python3 -c '
import sys
string: str = sys.argv[1]
separator: str = sys.argv[2]

for part in string.split(separator)[::-1]:
    print(part)
    ' "${string}" "${separator}"
}

function prepend_value {
    local varname="$1"
    local value="$2"

    if ! printenv "${varname}" | grep -qE "(^|:)${value}($|:)"; then
        export "${varname}"="${value}:$(printenv "${varname}")"
    fi
}

function set_env {
    local varname="$1"
    local value="$2"

    local -a restricted=(
        HOME
        SHELL
        USER
        PWD
        OLDPWD
        SHLVL
    )

    local -a colon_separeted=(
        PATH
        LD_LIBRARY_PATH
    )

    for r in "${restricted[@]}"; do
        if [[ "${varname}" = "${r}" ]]; then
            return
        fi
    done

    for c in "${colon_separeted[@]}"; do
        if [[ "${varname}" = "${c}" ]]; then
            while IFS= read -r part; do
                prepend_value "${varname}" "${part}"
            done <<<"$(splitvar "${value}" ":")"
            return
        fi
    done

    export "${varname}"="${value}"
}

# >>> environment variables >>>
set_env COLORTERM "truecolor"
set_env DOTFILES "${HOME}/.dotfiles"
set_env VISUAL "nvim"
set_env EDITOR "${VISUAL}"
set_env SUDO_EDITOR "${VISUAL}"
set_env JAVA_HOME "/usr/java/latest"
set_env MAMBA_NO_BANNER "1"
set_env MANROFFOPT "-c"
set_env PAGER "bat --plain"
set_env MANPAGER "nvimpager"
set_env BAT_PAGER ""
set_env RIPGREP_CONFIG_PATH "${XDG_CONFIG_HOME:-${HOME}/.config}/ripgrep/ripgreprc"
set_env HISTSIZE "100000"
set_env SAVEHIST "100000"
set_env FZF_DEFAULT_OPTS_FILE "${XDG_CONFIG_HOME:-${HOME}/.config}/fzf/fzfrc"
set_env PATH "${HOME}/.cargo/bin:${HOME}/.local/bin:${HOME}/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"

case "$(ps -p $$ -o comm=)" in
    "zsh")
        set_env HISTFILE "${XDG_STATE_HOME:-${HOME}/.local/state}/zsh/zsh_history"

        fpath+=("${XDG_DATA_HOME:-${HOME}/.local/share}/zsh/completions")
        export fpath
        ;;
    "bash")
        set_env HISTFILE "${XDG_STATE_HOME:-${HOME}/.local/state}/bash/bash_history"
        set_env HISTCONTROL "ignoreboth"
        ;;
esac

unset splitvar prepend_value set_env
# <<< environment variables <<<
