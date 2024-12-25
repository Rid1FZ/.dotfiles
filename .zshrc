#!/bin/env zsh

# >>> source global definitions >>>
[[ -f "/etc/zshrc" ]] && . "/etc/zshrc"
# <<< source global definitions <<<

# >>> source local configs >>>
function __source_rc {
	local rc
	rc="${1}"

	source "${HOME}"/.zprofile.d/"${rc}"
}

__source_rc "options.zsh"
__source_rc "keybindings.zsh"
__source_rc "completion.zsh"
__source_rc "syntax-highlighting.zsh"
__source_rc "env_vars.zsh"
__source_rc "prompt.zsh"
__source_rc "aliases.zsh"
__source_rc "functions.zsh"
__source_rc "plugins.zsh"

unset __source_rc
# <<< source local configs <<<
