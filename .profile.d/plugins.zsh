#!/bin/env zsh

# >>> plugins integration >>>
__plugins=(
	"/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh:/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh:/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
	"/usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh:/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh:/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
	"/usr/share/fzf/shell/key-bindings.zsh:/usr/share/fzf/key-bindings.zsh"
	"/usr/share/fzf/completion.zsh"
)

for __plugin in $__plugins; do
	__scripts=(${(@s/:/)__plugin})
	for __script in ${__scripts[@]}; do
		if [ -f "$__script" ]; then
			. "$__script"
			break
		fi
	done
done

unset __plugins __plugin __scripts __script
# <<< plugins integration <<<

# >>> fzf integration >>>
source <(fzf --zsh)
# <<< fzf integration <<<
