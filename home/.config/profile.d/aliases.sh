#!/bin/env bash

# >>> aliases >>>
eza_cmd="eza --classify --oneline --color=auto --icons --group-directories-first"
leza_cmd="${eza_cmd} --modified --links --group --long --git --git-repos --header"

alias ls="${eza_cmd}"
alias la="${eza_cmd} --all"
alias ll="${leza_cmd}"
alias lla="${leza_cmd} --all"
alias du="gdu --non-interactive --config-file=\$HOME/.config/gdu/gdu.yaml"
alias cat="bat"
alias diff="colordiff"
alias rg="rg --ignore-case"
alias cdd="cd \$DOTFILES"
alias cat="bat"
alias emacss="emacs --script"
alias update-grub="sudo grub2-mkconfig -o /boot/grub2/grub.cfg"

unset eza_cmd leza_cmd
# <<< aliases <<<
