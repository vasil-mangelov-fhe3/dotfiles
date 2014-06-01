#!/bin/bash
BASH_IT="${HOME}/.bash_it"

function load_defaults() {
	FILETYPE=${1}
	[ ! -d "${BASH_IT}/${FILETYPE}/enabled" ] && mkdir "${BASH_IT}/${FILETYPE}/enabled"
	for FILENAME in `cat $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/${FILETYPE}/defaults`; do
		SRC="${BASH_IT}/${FILETYPE}/available/${FILENAME}"
		[ ${FILENAME:0:1} = "_" ] && continue
		DEST="${BASH_IT}/${FILETYPE}/enabled/${FILENAME}"
		if [ -e ${SRC} ]; then
			ln -sf "${SRC}" "${DEST}"
		fi
	done
}

for TYPE in "aliases plugins completion"; do
	case "${1}" in
		"defaults")
			load_defaults ${TYPE}
			;;
		"forcedefaults")
			[[ -d ${BASH_IT}/${TYPE}/enabled/ ]] && rm -r ${BASH_IT}/${TYPE}/enabled/*
			load_defaults ${TYPE}
			;;
	esac
done
