#!/bin/env zsh

# >>> key timeout >>>
export KEYTIMEOUT=25
# <<< key timeout <<<

bindkey -v '^?' backward-delete-char

# >>> change cursor for different modes >>>
function zle-keymap-select {
    case $KEYMAP in
        vicmd) echo -ne '\e[2 q';;      # block
        viins|main) echo -ne '\e[6 q';; # beam
    esac
}
zle -N zle-keymap-select

function zle-line-init {
    zle -K viins
    echo -ne "\e[6 q"
}
zle -N zle-line-init

echo -ne '\e[6 q'

function preexec {
    echo -ne '\e[6 q' 
}
# <<< change cursor for different modes <<<

# >>> add text object for quotes and braces >>>
autoload -Uz select-bracketed select-quoted
zle -N select-quoted
zle -N select-bracketed
for m in viopp visual; do
  for c in {a,i}{\',\",\`}; do
      bindkey -M $m -- $c select-quoted
  done
  for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
      bindkey -M $m -- $c select-bracketed
  done
done
# <<< add text object for quotes and braces <<<

# >>> add surround like commands >>>
autoload -Uz surround
zle -N delete-surround surround
zle -N add-surround surround
zle -N change-surround surround
bindkey -M vicmd cs change-surround
bindkey -M vicmd ds delete-surround
bindkey -M vicmd ys add-surround
bindkey -M visual S add-surround
# <<< add surround like commands <<<

# >>> use `jj` and `jk` to return to normal mode >>>
bindkey -M viins "jj" vi-cmd-mode
bindkey -M viins "jk" vi-cmd-mode
# <<< use `jj` and `jk` to return to normal mode <<<
