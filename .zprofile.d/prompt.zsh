#!/bin/env zsh

# >>> prompt >>>
typeset -g VIRTUAL_ENV_DISABLE_PROMPT=1
setopt prompt_subst nopromptbang prompt{cr,percent,sp,subst}
autoload -Uz vcs_info add-zsh-hook
zstyle ':vcs_info:*' enable git svn
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '*'
zstyle ':vcs_info:*' stagedstr '+'
zstyle ':vcs_info:git*' formats " %F{magenta}%b%u%c%f"

function set_prompt {
    PS1=''
    [[ -n "${CONDA_DEFAULT_ENV}" ]] && PS1+=$'%F{green}(${CONDA_DEFAULT_ENV})%f'
    PS1+='%(?.%F{white}.%F{red})%#%f '

    RPS1=''
    [[ -n "${CONTAINER_ID}" || -n "${container}" ]] && RPS1+=' %B%F{green} %f%b'
}

function precmd {
    set_prompt
    vcs_info

    pre_prompt=$'\n'
    pre_prompt+=$'%B%F{blue}%~%f%b${vcs_info_msg_0_}%F{yellow}%(1j. %j󰜎 .)%f'
    print -rP "${pre_prompt}"
}
# <<< prompt <<<
