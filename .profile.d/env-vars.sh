#!/bin/env bash

function reverse_colon_values {
    local string="${1}"

    echo "${string}" |
        awk -F: '
            END {
                for (i=NF; i>0; i--) print $i
            }
        '
}

function prepend_value {
    local varname="${1}"
    local value="${2}"

    if ! printenv "${varname}" | grep -qE "(^|:)${value}($|:)"; then
        export "${varname}"="${value}:$(printenv "${varname}")"
    fi
}

function set_env {
    local varname="${1}"
    local value="${2}"

    local restricted_vars="HOME:SHELL:USER:PWD:OLDPWD:SHLVL"
    local csv_vars="PATH:LD_LIBRARY_PATH"

    if echo "${restricted_vars}" | grep -qE "(^|:)${varname}($|:)"; then
        return 0
    fi

    if echo "${csv_vars}" | grep -qE "(^|:)${varname}($|:)"; then
        while IFS= read -r part; do
            prepend_value "${varname}" "${part}"
        done <<<"$(reverse_colon_values "${value}")"
        return 0
    fi

    export "${varname}"="${value}"
}

# >>> environment variables >>>
set_env COLORTERM "truecolor"
set_env DOTFILES "${HOME}/.dotfiles"
set_env VISUAL "nvim"
set_env EDITOR "${VISUAL}"
set_env SUDO_EDITOR "${VISUAL}"
set_env MAMBA_NO_BANNER "1"
set_env MANROFFOPT "-c"
set_env PAGER "less"
set_env LESS "-R -i -M -g"
set_env MANPAGER "sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat --pager=less --paging=always -p -lman'"
set_env BAT_PAGER ""
set_env RIPGREP_CONFIG_PATH "${XDG_CONFIG_HOME:-${HOME}/.config}/ripgrep/ripgreprc"
set_env HISTSIZE "100000"
set_env SAVEHIST "100000"
set_env FZF_DEFAULT_OPTS_FILE "${XDG_CONFIG_HOME:-${HOME}/.config}/fzf/fzfrc"

# Android
set_env JAVA_HOME "/usr/lib/jvm/jre-21-openjdk"
set_env ANDROID_HOME "${HOME}/Android"
set_env ANDROID_SDK_ROOT "${HOME}/Android"

set_env PATH "${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${HOME}/.cargo/bin:${HOME}/.local/bin:${HOME}/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"
set_env LD_LIBRARY_PATH "${ANDROID_SDK_ROOT}/cmdline-tools/latest/lib:${ANDROID_SDK_ROOT}/platform-tools"

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

unset reverse_colon_values prepend_value set_env
# <<< environment variables <<<
