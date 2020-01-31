#!/bin/bash
export MARKPATH=$HOME/.marks

if [[ ! -d "${MARKPATH}" ]]; then
	mkdir "${MARKPATH}"
fi

function j(){
	if [[ -z "$1" ]]; then
		echo "Usage: j <mark>" >&2
		return 1
	fi
	cd -P "$MARKPATH/$1" 2>/dev/null || echo "No such mark: $1"
}

function m(){
	mkdir -p "$MARKPATH"; ln -s "$(pwd)" "$MARKPATH/$1"
}

function um(){
	rm -i "$MARKPATH/$1"
}

function marks(){
	ls -l "$MARKPATH" | sed 's/  / /g' | cut -d' ' -f9- | sed 's/ -/\t-/g' && echo
}

function _completemarks(){
  reply=($(ls $MARKPATH))
}

compctl -K _completemarks j
compctl -K _completemarks um