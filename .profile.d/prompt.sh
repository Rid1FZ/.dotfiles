#!/bin/env bash

# >>> prompt >>>
function set_prompt {
    RED='\033[1;31m'
    GREEN='\033[1;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[1;34m'
    NC='\033[0m'

    PS1=''

    if [[ -n "${VIRTUAL_ENV_PROMPT}" ]]; then
        PS1+="${YELLOW}${VIRTUAL_ENV_PROMPT}${NC}"
    elif [[ -n "${CONDA_DEFAULT_ENV}" ]]; then
        PS1+="${GREEN}(${CONDA_DEFAULT_ENV})${NC} "
    fi

    PS1+=$'\$ '

    printf "\n"
    printf "${BLUE}%s${NC}\n" "${PWD/#$HOME/\~}"
}

PROMPT_COMMAND='set_prompt'
# <<< prompt <<<
