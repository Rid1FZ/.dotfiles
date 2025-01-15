#!/bin/env zsh

# >>> zsh keybindings >>>
autoload edit-command-line
zle -N edit-command-line

bindkey -e

bindkey '^x^e' edit-command-line
# <<< zsh keybindings <<<
