#!/bin/env bash

# >>> environment variables >>>
export PATH="${HOME}/.cargo/bin:${HOME}/.local/bin:${HOME}/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"
export COLORTERM="truecolor"
export DOTFILES="${HOME}/.dotfiles"
export VISUAL="nvim"
export EDITOR="${VISUAL}"
export SUDO_EDITOR="${VISUAL}"
export JAVA_HOME="/usr/java/latest"
export MAMBA_NO_BANNER=1
export MANROFFOPT="-c"
export PAGER="bat --plain"
export MANPAGER="nvimpager"
export BAT_PAGER=""
export RIPGREP_CONFIG_PATH="${XDG_CONFIG_HOME:-${HOME}/.config}/ripgrep/ripgreprc"
export HISTSIZE=100000
export SAVEHIST=100000
export FZF_DEFAULT_OPTS_FILE="${XDG_CONFIG_HOME:-${HOME}/.config}/fzf/fzfrc"

case "$(ps -p $$ -o comm=)" in
    "zsh")
        export HISTFILE="${XDG_STATE_HOME:-${HOME}/.local/state}/zsh/zsh_history"
        fpath+=("${XDG_DATA_HOME:-${HOME}/.local/share}/zsh/completions")
        export fpath
        ;;
    "bash")
        export HISTFILE="${XDG_STATE_HOME:-${HOME}/.local/state}/bash/bash_history"
        export HISTCONTROL="ignoreboth"
        ;;
esac
# <<< environment variables <<<
