#!/bin/bash

# Enable automatic exporting of variables
set -a

# Loop through and source all readable .conf files
for conf in "${HOME}/.config/environment.d/"*.conf; do
    if [ -r "${conf}" ]; then
        source "${conf}"
    fi
done

PROFILE_PATH="${XDG_CONFIG_HOME}/profile.d:${HOME}/.profile.d:${DOTFILES}/home/.profile.d"

IFS=':' read -ra dirs <<<"$PROFILE_PATH"

for dir in "${dirs[@]}"; do
    for ext in bash sh; do
        [[ -f "${dir}/env-vars.${ext}" ]] || continue
        source "${dir}/env-vars.${ext}"
        break
    done
done

# Disable automatic exporting
set +a
