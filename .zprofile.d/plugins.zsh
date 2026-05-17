#!/bin/env zsh

# >>> fzf integration >>>
source <(fzf --zsh)
# <<< fzf integration <<<

# >>> direnv integration >>>
eval "$(direnv hook zsh)"
# <<< direnv integration <<<

# >>> source plugins from plugins directory >>>
__plugin_dirs="${XDG_DATA_HOME:-${HOME}/.local/share}/zsh/plugins:${HOME}/.zsh/plugins"
__dirs=(${(@s/:/)__plugin_dirs})

for __dir in ${__dirs[@]}; do
    if [[ -d "${__dir}" ]]; then
        for __plugin in "${__dir}"/**/*.plugin.zsh; do
            source "${__plugin}"
        done
    fi
done

unset __plugin_dirs __dirs __dir __plugin
# <<< source plugins from plugins directory <<<
