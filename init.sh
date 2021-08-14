#!/bin/bash

function crash_include() {
	local dir
	local file
	local lib_path
	if [ "$#" -lt 1 ]
	then
		echo "[lib-crash] include failed: missing argument"
		exit 1
	fi

	dir="$(pwd)"
	file="$1"
	lib_path="$HOME/.lib-crash"
	if [ "$LIB_CRASH_PATH" != "" ]
	then
		lib_path="$LIB_CRASH_PATH"
	fi

	if [ ! -d "$lib_path" ]
	then
		echo "[lib-crash] include failed: lib-crash not found '$lib_path'"
		exit 1
	fi

	if [ ! -f "$lib_path/$file" ]
	then
		echo "[lib-crash] include failed: file not found '$lib_path/$file'"
		exit 1
	fi

	# get path to file and navigate there
	# so relative includes still work
	cd "$lib_path/" || exit 1
	if [[ "$file" =~ / ]]
	then
		cd "${file%/*}" || exit 1
	fi
	# shellcheck source=logger.sh
	source "$lib_path/$file"
	cd "$dir" || exit 1
}
function crash_install() {
	local repo
	local lib
	local lib_path
	if [ "$#" -lt 1 ]
	then
		echo "[lib-crash] install failed: missing argument"
		return 1
	fi

	repo="$1"
	repo="${repo%%+(/)}" # strip trailing slash
	lib="${repo##*/}"    # get last word after slash
	lib_path="$HOME/.lib-crash"
	if [ "$LIB_CRASH_PATH" != "" ]
	then
		lib_path="$LIB_CRASH_PATH"
	fi

	if [ ! -d "$lib_path" ]
	then
		echo "[lib-crash] install failed: lib-crash not found '$lib_path'"
		return 1
	fi

	if [ -d "$lib_path/$lib" ]
	then
		echo "[lib-crash] install failed: lib installed already '$lib_path/$lib'"
		return 1
	fi

	git clone --recursive "$repo" "$lib_path/$lib"
}
export -f crash_include
export -f crash_install
export LIB_CRASH_VERSION='v1.0.0'

