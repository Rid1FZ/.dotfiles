#!/bin/env bash

# >>> prompt >>>
function set_prompt {
    local yellow='\[\033[1;33m\]' green='\[\033[1;32m\]' nc='\[\033[0m\]'
    local dir="${PWD}"

    PS1=''

    if [[ -n "${VIRTUAL_ENV_PROMPT}" ]]; then
        PS1+="${yellow}(${VIRTUAL_ENV_PROMPT})${nc}"
    elif [[ -n "${CONDA_DEFAULT_ENV}" ]]; then
        PS1+="${green}(${CONDA_DEFAULT_ENV})${nc}"
    fi

    PS1+='\$ '

    if [[ "${dir}" == "${HOME}" || "${dir}" == "${HOME}"/* ]]; then
        dir="~${dir#"${HOME}"}"
    fi

    printf '\n\033[1;34m%s\033[0m\n' "${dir}"
}

# prepend instead of overwriting, so hooks set elsewhere (e.g. /etc/bashrc) keep working
case ";${PROMPT_COMMAND};" in
*";set_prompt;"*) ;;
*) PROMPT_COMMAND="set_prompt${PROMPT_COMMAND:+;${PROMPT_COMMAND}}" ;;
esac
# <<< prompt <<<
