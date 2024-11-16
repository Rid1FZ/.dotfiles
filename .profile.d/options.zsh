#!/bin/env zsh

# >>> Options >>>
setopt GLOB_DOTS AUTO_CD GLOB_COMPLETE MENU_COMPLETE AUTO_LIST COMPLETE_IN_WORD
compinit -d "${XDG_CACHE_HOME:-${HOME}/.cache}/zsh/zcompdump"
# <<< Options <<<
