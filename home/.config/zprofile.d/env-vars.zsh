#!/bin/env zsh

local PROFILE_PATH dir ext
PROFILE_PATH="${XDG_CONFIG_HOME}/profile.d:${HOME}/.profile.d:${DOTFILES}/home/.profile.d"

for dir in ${(s.:.)PROFILE_PATH}; do
    for ext in bash sh; do
        [[ -f "${dir}/env-vars.${ext}" ]] || continue
        source "${dir}/env-vars.${ext}"
        break
    done
done
