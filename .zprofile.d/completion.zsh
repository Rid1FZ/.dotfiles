#!/bin/env zsh

# >>> completion >>>
zmodload zsh/complist
bindkey -M menuselect '^xg' clear-screen
bindkey -M menuselect '^xi' vi-insert                      # Insert
bindkey -M menuselect '^xh' accept-and-hold                # Hold
bindkey -M menuselect '^xn' accept-and-infer-next-history  # Next
bindkey -M menuselect '^xu' undo                           # Undo
bindkey -M menuselect '^[[Z' reverse-menu-complete         # Shift+Tab
bindkey -M menuselect '\r' .accept-line
bindkey '^Xa' alias-expension

autoload -U compinit; compinit
_comp_options+=(globdots)
compdef vman="man"
setopt GLOB_COMPLETE
setopt MENU_COMPLETE
setopt AUTO_LIST
setopt COMPLETE_IN_WORD

# Ztyle pattern
zle -C alias-expension complete-word _generic
# :completion:<function>:<completer>:<command>:<argument>:<tag>
zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
zstyle ':completion:*:*:*:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:*:*:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*:aliases' list-colors '=*=35'
zstyle ':completion:*:default' list-colors \
	'=(#b)*(-- *)=39=38;5;245' \
	"$LS_COLORS" \
	"ma=7;38;5;68"
zstyle ':completion:*' completer _extensions _complete _approximate
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-${HOME}/.cache}/zsh/zcompcache"
zstyle ':completion:*' complete true
zstyle ':completion:alias-expension:*' completer _expand_alias
zstyle ':completion:*' menu select
zstyle ':completion:*' complete-options true
zstyle ':completion:*' file-sort modification
zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*' group-name ''
zstyle ':completion:*:*:-command-:*:*' group-order aliases builtins functions commands
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' keep-prefix true
zstyle -e ':completion:*:(ssh|scp|sftp|rsh|rsync):hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'
# <<< completion <<<

# >>> load zsh-autosuggestions >>>
__zsh_autosuggestion_path="/usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh:/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh:/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
__scripts=(${(@s/:/)__zsh_autosuggestion_path})

for __script in ${__scripts[@]}; do
  if [ -f "${__script}" ]; then
    . "${__script}"
    break
  fi
done

unset __zsh_autosuggestion_path __scripts __script
# <<< load zsh-autosuggestions <<<
