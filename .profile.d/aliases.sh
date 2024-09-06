#!/bin/env bash

# >>> aliases >>>
eza_cmd="eza --classify --oneline --color=always --icons --group-directories-first"
leza_cmd="${eza_cmd} --inode --modified --octal-permissions --links --group --long --git"

alias ls="${eza_cmd}"
alias la="${eza_cmd} --all"
alias ll="${leza_cmd}"
alias lla="${leza_cmd} --all"
alias du="gdu --non-interactive --config-file=\$HOME/.config/gdu/gdu.yaml"
alias cat="bat"
alias diff="colordiff"
alias rg="rg --ignore-case"
alias tree="eza --classify --icons --group-directories-first --tree"
alias rm="trash"
alias cdd="cd \$DOTFILES"

unset eza_cmd leza_cmd

# <<< aliases <<<
