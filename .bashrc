#!/bin/env bash

# >>> source global definitions >>>
[[ -f "/etc/bashrc" ]] && . "/etc/bashrc"
# <<< source global definitions <<<

# >>> source local configs >>>
function __source_rc {
	local rc
	rc="${1}"

	source "${HOME}"/.profile.d/"${rc}"
}

__source_rc "options.sh"
__source_rc "env_vars.sh"
__source_rc "prompt.sh"
__source_rc "aliases.sh"
__source_rc "functions.sh"
__source_rc "plugins.sh"

unset __source_rc
# <<< source local configs <<<
