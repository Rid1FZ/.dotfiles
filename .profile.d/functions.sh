#!/bin/env bash

# >>> functions >>>
function open {
	case "$(file -b --mime-type --dereference "${1}")" in
		inode/directory )
			builtin cd -- "${1}" || return 1
			;;
		text/* | application/javascript | application/toml | application/x-shellscript | application/x-zerosize )
			exec "${EDITOR} \"${1}\""
			;;
		* )
			xdg-open "$1" &>/dev/null || {
				printf "\033[0;31m[error]\033[0m: xdg-open failed\n"
				printf "enter command to open file: "
				read -r cmd
				exec "${cmd} ${1}"
			}
			;;
	esac
}

function floc {
	PREFIX="plocate --ignore-case --regex"
	
	target="$(fzf --disabled --keep-right --ansi --bind "start:reload:${PREFIX} {q}" --bind "change:reload:sleep 0.1; ${PREFIX} {q} || true" --preview 'preview {}' --height=100% --preview-window 'right,60%,border-left')"
	[[ -z "${target}" ]] && return 1
	
	open "${target}"
}

function ff {
	arg="${1:-.}"
	[[ -d "${arg}" ]] || return 1

	_path="$(fd -Ha --no-ignore --type symlink --type file --follow ".*" "${arg}" | fzf --ansi --keep-right --height=100% --preview="preview {}" --preview-window 'right,60%,border-left')"
	[[ -z "${_path}" ]] && return 1
	
	open "${_path}"
}

function fcd {
	arg="${1:-.}"
	[[ -d "${arg}" ]] || return 1
	builtin cd -- "$(fd -Ha --no-ignore --type directory --follow ".*" "${arg}" | fzf --ansi --keep-right --height=100% --preview="preview {}" --preview-window 'top,60%,border-bottom')" || return 1
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


function rm {
	(( "$#" == 0 )) && echo "error: please specify file to remove..." >&2
	to_trash=()

	for arg in "$@"; do
		if [[ -L "${arg}" ]]; then
			unlink "${arg}"
		else
			to_trash+=("${arg}")
		fi
	done

	(( "${#to_trash[@]}" != 0 )) && trash-put "${to_trash[@]}"
}

function mkfile {
	(( "$#" == 0 )) && echo "error: please specify at-least one filename to create..." >&2

	for file in "$@"; do
		parent_dir="$(realpath "$(dirname "${file}")")"
		if [[ -e "${parent_dir}" ]] && ! [[ -d "${parent_dir}" ]]; then
			echo "error: ${parent_dir} already exists and is not a directory..." >&2
			continue
		fi

		mkdir -p "${parent_dir}"
		touch "${file}"
	done
}
# <<< functions <<<
