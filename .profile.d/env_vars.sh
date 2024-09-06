#!/bin/env bash

# >>> environment variables >>>
export PATH="${HOME}/.cargo/bin:${HOME}/.local/bin:${HOME}/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"
export COLORTERM="truecolor"
export DOTFILES="${HOME}/.dotfiles"
export VISUAL="nvim"
export EDITOR="${VISUAL}"
export SUDO_EDITOR="${VISUAL}"
export JAVA_HOME="/usr/java/latest"
export MAMBA_NO_BANNER=1
export MANROFFOPT="-c"
export PAGER="bat --plain"
export MANPAGER="page -t man"
export BAT_PAGER=""
[[ "$(basename "${SHELL}")" = "zsh" ]] && export HISTFILE="${HOME}/.zsh_history"
export HISTSIZE=100000
export SAVEHIST=100000
export FZF_DEFAULT_OPTS=" \
--layout=reverse --no-mouse --cycle --scroll-off=1 --no-scrollbar \
--bind 'tab:toggle-down,btab:toggle-up' --border=rounded \
--prompt=\" \" --pointer=\"\" --marker=\" \" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
# <<< environment variables <<<
