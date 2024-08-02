#!/bin/env bash

# >>> prompt >>>
# PROMPT_COMMAND='printf "\n\033[0;34m[\033[0;33m%s\033[0m@\033[0;35m%s \033[0;34m%s]\033[0m\n" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"'
PROMPT_COMMAND='printf "\n\033[1;33m%s\033[0m:\033[1;34m[%s]\033[0m\n" "${USER}" "${PWD/#$HOME/\~}"'
PS1=$'\$ '
# <<< prompt <<<
