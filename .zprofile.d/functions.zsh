#!/bin/env zsh

local PROFILE_PATH
PROFILE_PATH="${HOME}/.profile.d:${DOTFILES}/.profile.d"

for dir in ${(s.:.)PROFILE_PATH}; do
    for ext in bash sh; do
        [[ -f "${dir}/functions.${ext}" ]] || continue
        source "${dir}/functions.${ext}"
        break
    done
done
