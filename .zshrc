#!/bin/env zsh

# >>> source global definitions >>>
[[ -f "/etc/zshrc" ]] && . "/etc/zshrc"
# <<< source global definitions <<<

# >>> source local configs >>>
for rc in "${HOME}"/.profile.d/*.zsh; do . "$rc"; done
# <<< source local configs <<<
