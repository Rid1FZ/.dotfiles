#!/bin/env zsh

# >>> Options >>>
setopt AUTO_CD \
    AUTO_LIST \
    COMPLETE_IN_WORD \
    GLOB_COMPLETE \
    GLOB_DOTS \
    MENU_COMPLETE \
    PIPE_FAIL \
    PROMPT_SUBST \
    SHARE_HISTORY

compinit -d "${XDG_CACHE_HOME:-${HOME}/.cache}/zsh/zcompdump"
# <<< Options <<<
