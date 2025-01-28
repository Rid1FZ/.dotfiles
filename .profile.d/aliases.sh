#!/bin/env bash

# >>> aliases >>>
eza_cmd="eza --classify --oneline --color=always --icons --group-directories-first"
leza_cmd="${eza_cmd} --modified --links --group --long --git --git-repos --header"

alias ls="${eza_cmd}"
alias la="${eza_cmd} --all"
alias ll="${leza_cmd}"
alias lla="${leza_cmd} --all"
alias du="gdu --non-interactive --config-file=\$HOME/.config/gdu/gdu.yaml"
alias cat="bat"
alias diff="colordiff"
alias rg="rg --ignore-case"
alias tree="${eza_cmd} --tree --ignore-glob=.git --git-ignore"
alias cdd="cd \$DOTFILES"
alias cat="bat"

unset eza_cmd leza_cmd
# <<< aliases <<<
