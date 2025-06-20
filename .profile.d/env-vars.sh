#!/bin/env bash

function set_env {
    local name=$1
    local value=$2
    local -a reserved=(
        PATH
        HOME
        SHELL
        USER
        PWD
        OLDPWD
        SHLVL
        LD_LIBRARY_PATH
    )

    for r in "${reserved[@]}"; do
        if [[ "${name}" == "${r}" ]]; then
            return 0
        fi
    done

    export "$name"="$value"
    return 0
}

# >>> environment variables >>>
set_env PATH "${HOME}/.cargo/bin:${HOME}/.local/bin:${HOME}/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"
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

unset set_env
# <<< environment variables <<<
