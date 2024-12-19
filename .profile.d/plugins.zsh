#!/bin/env zsh

# >>> fzf integration >>>
source <(fzf --zsh)
# <<< fzf integration <<<

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$("${HOME}/.mamba/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "${HOME}/.mamba/etc/profile.d/conda.sh" ]; then
        . "${HOME}/.mamba/etc/profile.d/conda.sh"
    else
        export PATH="${HOME}/.mamba/bin:$PATH"
    fi
fi
unset __conda_setup

if [ -f "${HOME}/.mamba/etc/profile.d/mamba.sh" ]; then
    . "${HOME}/.mamba/etc/profile.d/mamba.sh"
fi
# <<< conda initialize <<<

# >>> source plugins from plugins directory >>>
__plugin_dirs="${XDG_DATA_HOME:-${HOME}/.local/share}/zsh/plugins:${HOME}/.zsh/plugins"
__dirs=(${(@s/:/)__plugin_dirs})

for __dir in ${__dirs[@]}; do
  if [[ -d "${__dir}" ]]; then
    for __plugin in "${__dir}"/**/*.plugin.zsh; do
      . "${__plugin}"
    done
  fi
done

unset __plugin_dirs __dirs __dir __plugin
# <<< source plugins from plugins directory <<<
