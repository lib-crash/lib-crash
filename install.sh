#!/bin/bash

B='\033[1m'
R='\033[0m'

if [ "$1" == "--help" ] || [ "$1" == "-h" ]
then
    echo    "usage: $0 [github|local|uninstall] [PATH]"
    echo -e "  ${B}local${R}     - install from current directory"
    echo -e "  ${B}github${R}    - install from github (default)"
    echo -e "  ${B}uninstall${R} - delete library"
    echo -e "  ${B}PATH${R}      - library path default: /usr/lib/lib-crash"
    exit 0
fi

function log() {
    echo "[lib-crash] $1"
}

read -rd '' crash_include << EOF
# shellcheck shell=bash
# shellcheck source=/dev/null
function crash_include() {
    if [ "\$#" -lt 1 ]
    then
        echo "[lib-crash] include failed: missing argument"
        exit 1
    fi

    file="\$1"
    lib_path=/usr/lib/lib-crash
    if [ "\$LIB_CRASH_PATH" != "" ]
    then
        lib_path="\$LIB_CRASH_PATH"
    fi

    if [ ! -d "\$lib_path" ]
    then
        echo "[lib-crash] include failed: lib-crash not found '\$lib_path'"
        exit 1
    fi

    if [ ! -f "\$lib_path/\$file" ]
    then
        echo "[lib-crash] include failed: file not found '\$lib_path/\$file'"
        exit 1
    fi

    . "\$lib_path/\$file"
}
export -f crash_include >> /tmp/lib-crash-err 2>&1
EOF

arg_method=${1:-local}
arg_path=${2:-/usr/lib/lib-crash}
bash_file=""
if [ -d /etc/profile.d/ ]
then
    bash_file=/etc/profile.d/lib-crash.sh
else
    log "install failed: unsupported os"
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
    if [ -f "$bash_file" ]
    then
        # make sure to never delete/overwrite something
        log "install failed: '$bash_file' exist already"
        exit 1
    fi
    echo "$crash_include" > "$bash_file" || exit 1
}

if [ "$arg_method" == "local" ]
then
    pre_install
    cp -r . "$arg_path"
elif [ "$arg_method" == "github" ]
then
    pre_install
    git clone https://github.com/lib-crash/lib-crash "$arg_path"
elif [ "$arg_method" == "uninstall" ]
then
    rm -r "$arg_path" || exit 1
    rm "$bash_file" || exit 1
    log "successfully uninstalled lib-crash"
else
    log "invalid argument '$arg_method' visit help page"
    echo "$0 --help"
    exit 1
fi

