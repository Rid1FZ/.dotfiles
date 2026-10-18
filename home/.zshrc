#!/bin/env zsh

# zsh already reads /etc/zshrc by itself before this file, so it is not sourced again here.

# >>> source local configs >>>
function __source_rc {
    local rc
    rc="${1}"

    source "${XDG_CONFIG_HOME:="${HOME}/.config"}"/zprofile.d/"${rc}"
}

__source_rc "options.zsh"
__source_rc "keybindings.zsh"
__source_rc "completion.zsh"
__source_rc "env-vars.zsh"
__source_rc "prompt.zsh"
__source_rc "aliases.zsh"
__source_rc "functions.zsh"
__source_rc "plugins.zsh"

# zsh-syntax-highlighting must be sourced last: it wraps every ZLE widget that exists
# at load time, so widgets created later (fzf, plugins, ...) would not be highlighted.
__source_rc "syntax-highlighting.zsh"

unfunction __source_rc
# <<< source local configs <<<
