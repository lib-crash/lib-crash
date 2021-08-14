#!/bin/bash

B='\033[1m'
R='\033[0m'

if [ "$1" == "--help" ] || [ "$1" == "-h" ]
then
	echo    "usage: $0 [github|local|uninstall] [PATH]"
	echo -e "  ${B}local${R}     - install from current directory"
	echo -e "  ${B}github${R}    - install from github (default)"
	echo -e "  ${B}uninstall${R} - delete library"
	echo -e "  ${B}PATH${R}      - library path default: $HOME/.lib-crash/lib-crash/lib-crash"
	exit 0
fi

function log() {
	echo "[lib-crash] $1"
}


arg_method=${1:-github}
arg_path=${2:-$HOME/.lib-crash/lib-crash/lib-crash}

if [ "$arg_method" == "local" ] && [ -f "$arg_path/init.sh" ]
then
	installed_version="$LIB_CRASH_VERSION"
	# TODO: delete directive when githubs shellcheck updated
	# shellcheck source=init.sh
	source "$arg_path/init.sh"
	if [ "$LIB_CRASH_VERSION" == "$installed_version" ]
	then
		log "lib-crash is already latest version '$LIB_CRASH_VERSION'"
		log "to force a update uninstall first:"
		echo "./install.sh uninstall"
		exit 0
	fi
fi

bash_file=""
if [ -f "$HOME/.bashrc" ]
then
	bash_file="$HOME/.bashrc"
else
	log "install failed: ~/.bashrc not found"
	exit 1
fi

function pre_install() {
	if [ ! -d "$arg_path" ]
	then
		mkdir -p "$arg_path" || exit 1
	else
		if [ "$(ls -A "$arg_path")" ]
		then
			log "install failed: '$arg_path' is not empty"
			exit 1
		fi
	fi
	if grep -q "# lib-crash start" "$bash_file"
	then
		return
	fi
	# insert at start of file before any return
	echo "source $arg_path/init.sh # lib-crash init" | cat - "$bash_file" > /tmp/lib-crash-bashrc || exit 1
	mv /tmp/lib-crash-bashrc "$bash_file" || exit 1
}

if [ "$arg_method" == "local" ]
then
	pre_install
	cp -r . "$arg_path"
	log "install finished."
elif [ "$arg_method" == "github" ]
then
	pre_install
	git clone https://github.com/lib-crash/lib-crash "$arg_path"
	log "install finished."
elif [ "$arg_method" == "uninstall" ]
then
	rm -r "$arg_path" || exit 1
	sed -e '/.*# lib-crash init$/d' "$bash_file" > /tmp/lib-crash-bashrc_"$USER" || exit 1
	cp /tmp/lib-crash-bashrc_"$USER" "$bash_file" || exit 1
	rm /tmp/lib-crash-bashrc_"$USER"
	log "successfully uninstalled lib-crash"
else
	log "invalid argument '$arg_method' visit help page"
	echo "$0 --help"
	exit 1
fi

