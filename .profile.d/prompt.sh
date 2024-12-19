#!/bin/env bash

# >>> prompt >>>
function set_prompt {
	RED='\033[1;31m'
	GREEN='\033[1;32m'
	BLUE='\033[1;34m'
	NC='\033[0m'

	PS1=''
	[[ -n "${CONDA_DEFAULT_ENV}" ]] && PS1+="${GREEN}(${CONDA_DEFAULT_ENV})${NC}"
	PS1+=$'\$ '

	printf "\n"
	printf "${BLUE}%s${NC}\n" "${PWD/#$HOME/\~}"
}

PROMPT_COMMAND='set_prompt'
# <<< prompt <<<
