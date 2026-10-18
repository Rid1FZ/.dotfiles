#!/bin/env bash

# >>> source global definitions >>>
[[ -f "/etc/bashrc" ]] && source "/etc/bashrc"
# <<< source global definitions <<<

# >>> source local configs >>>
function __source_rc {
    local rc
    rc="${1}"

    source "${XDG_CONFIG_HOME:="${HOME}/.config"}"/profile.d/"${rc}"
}

__source_rc "env-vars.sh"

# bash also reads ~/.bashrc for non-interactive shells started by sshd: everything
# below changes shell options, aliases and prompts, so it is interactive-only.
if [[ $- != *i* ]]; then
    unset -f __source_rc
    return 0
fi

__source_rc "options.sh"
__source_rc "prompt.sh"
__source_rc "aliases.sh"
__source_rc "functions.sh"
__source_rc "plugins.sh"

unset -f __source_rc
# <<< source local configs <<<
