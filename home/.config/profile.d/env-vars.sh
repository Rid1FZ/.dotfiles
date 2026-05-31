#!/bin/env bash

# >>> utility functions for setting environment variables >>>
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
# <<< utility functions for setting environment variables <<<

# >>> environment variables >>>
set_env COLORTERM "truecolor"
set_env DOTFILES "${XDG_PROJECTS_DIR:=${HOME}/Projects}/dotfiles"
set_env VISUAL "nvim"
set_env EDITOR "${VISUAL}"
set_env SUDO_EDITOR "${VISUAL}"
set_env MAMBA_NO_BANNER "1"
set_env MANROFFOPT "-c"
set_env PAGER "less"
set_env LESS "-R -i -M -g"
set_env LESSHISTFILE "${XDG_STATE_HOME:="${HOME}/.local/state"}/less/history"
set_env MANPAGER "sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat --pager=less --paging=always -p -lman'"
set_env BAT_PAGER ""
set_env RIPGREP_CONFIG_PATH "${XDG_CONFIG_HOME:=${HOME}/.config}/ripgrep/ripgreprc"
set_env HISTSIZE "100000"
set_env SAVEHIST "100000"
set_env FZF_DEFAULT_OPTS_FILE "${XDG_CONFIG_HOME:=${HOME}/.config}/fzf/fzfrc"

# Android
set_env ANDROID_HOME "${XDG_DATA_HOME:="${HOME}/.local/share"}/android"
set_env ANDROID_USER_HOME "${XDG_CONFIG_HOME:="${HOME}/.config"}/android"

# Java
set_env JAVA_HOME "/usr/lib/jvm/jre-21-openjdk"

# Rust
set_env CARGO_HOME "${XDG_DATA_HOME:="${HOME}/.local/share"}/cargo"
set_env RUSTUP_HOME "${XDG_DATA_HOME:="${HOME}/.local/share"}/rustup"

# Go
set_env GOPATH "${XDG_DATA_HOME:="${HOME}/.local/share"}/go"
set_env GOCACHE "${XDG_CACHE_HOME:="${HOME}/.cache"}/go-build"

# NodeJS
set_env NPM_CONFIG_USERCONFIG "${XDG_CONFIG_HOME:="${HOME}/.config"}/npm/npmrc"
set_env NPM_CONFIG_CACHE "${XDG_CACHE_HOME:="${HOME}/.cache"}/npm"
set_env NPM_CONFIG_PREFIX "${XDG_DATA_HOME:="${HOME}/.local/share"}/npm"

# Python
set_env PYTHON_HISTORY "${XDG_STATE_HOME:="${HOME}/.local/state"}/python/history"
set_env PIP_CONFIG_FILE "${XDG_CONFIG_HOME:="${HOME}/.config"}/pip/pip.conf"
set_env PIP_CACHE_DIR "${XDG_CACHE_HOME:="${HOME}/.cache"}/pip"

# Docker
set_env DOCKER_CONFIG "${XDG_CONFIG_HOME:="${HOME}/.config"}/docker"

# Binary and Library paths
set_env PATH "${HOME}/.local/share/bob/nvim-bin:${ANDROID_HOME}/emulator:${ANDROID_HOME}/build-tools:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/cmdline-tools/latest/bin:${GOPATH}/bin:${CARGO_HOME}/bin:${NPM_CONFIG_PREFIX}/bin:${HOME}/.local/bin:${HOME}/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"
set_env LD_LIBRARY_PATH "${ANDROID_HOME}/cmdline-tools/latest/lib"

case "$(ps -p $$ -o comm=)" in
"zsh")
    set_env HISTFILE "${XDG_STATE_HOME:=${HOME}/.local/state}/zsh/zsh_history"

    fpath+=("${XDG_DATA_HOME:=${HOME}/.local/share}/zsh/completions")
    export fpath
    ;;
"bash")
    set_env HISTFILE "${XDG_STATE_HOME:=${HOME}/.local/state}/bash/bash_history"
    set_env HISTCONTROL "ignoreboth"
    ;;
esac
# <<< environment variables <<<

# >>> unset utility functions >>>
unset reverse_colon_values prepend_value set_env
# <<< unset utility functions <<<
