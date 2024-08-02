#!/bin/env bash

# >>> functions >>>

function ff {
	__arg="${1:-.}"
	test -d "${__arg}" || return 1

	__path="$(fd -Ha --no-ignore --type symlink --type file --follow ".*" "${__arg}" | fzf --ansi --height=100% --preview="_preview {}" --preview-window 'right,60%,border-left')"

	[ -z "${__path}" ] && return 1
	
	case "$(file -b --mime-type --dereference "${__path}")" in
		text/* | application/javascript | application/toml | application/x-shellscript | application/x-zerosize ) nvim "${__path}" ;;
		* )
			xdg-open "$1" &>/dev/null || {
				printf "enter command to run file: "
				read -r __command
				exec "${__command} ${__path}"
			}
			;;
	esac
}

function fcd {
	__arg="${1:-.}"
	test -d "$__arg" || return 1
	cd "$(fd -Ha --no-ignore --type directory --follow ".*" "${__arg}" | fzf --ansi --height=100% --preview="_preview {}" --preview-window 'top,60%,border-bottom')"
}

function fw {
	RG_PREFIX="rg --column --line-number --no-heading --hidden --follow --color=always --smart-case "
	fzf --disabled --ansi \
		--bind "start:reload:${RG_PREFIX} {q} ${1:-.}" \
		--bind "change:reload:sleep 0.1; ${RG_PREFIX} {q} || true" \
		--delimiter : \
		--preview 'bat --color=always {1} --highlight-line {2} --theme="Catppuccin Macchiato"' \
		--height=100% \
		--preview-window 'up,60%,border-bottom,+{2}-5/5' \
		--bind 'enter:become(nvim {1} +{2})'
}
# <<< functions <<<
