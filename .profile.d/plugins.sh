# >>> fzf integration >>>
source <(fzf --bash)
# <<< fzf integration <<<

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$("${HOME}/.mamba/bin/conda" 'shell.bash' 'hook' 2>/dev/null)"
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
# <<< conda initialize <<<
