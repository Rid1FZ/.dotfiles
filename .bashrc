#!/bin/env bash

# >>> source global definitions >>>
[[ -f "/etc/bashrc" ]] && . "/etc/bashrc"
# <<< source global definitions <<<

# >>> source local configs >>>
for rc in "${HOME}"/.profile.d/*.sh; do . "$rc"; done
# <<< source local configs <<<
