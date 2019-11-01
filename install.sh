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

current_version="v1.0.0"
if [ "$LIB_CRASH_VERSION" == "$current_version" ]
then
    log "lib-crash is already latest version '$current_version'"
    log "to force a update uninstall first:"
    echo "./install.sh uninstall"
    exit 0
fi

read -rd '' crash_include << EOF
# lib-crash start
function crash_include() {
    if [ "\$#" -lt 1 ]
    then
        echo "[lib-crash] include failed: missing argument"
        exit 1
    fi

    dir="\$(pwd)"
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

    # get path to file and navigate there
    # so relative includes still work
    cd "\$lib_path/"
    if [[ "\$file" =~ / ]]
    then
        cd "\${file%/*}"
    fi
    . "\$lib_path/\$file"
    cd "\$dir"
}
function crash_install() {
    if [ "\$#" -lt 1 ]
    then
        echo "[lib-crash] install failed: missing argument"
        return 1
    fi

    repo="\$1"
    repo="\${repo%%+(/)}" # strip trailing slash
    lib="\${repo##*/}"    # get last word after slash
    lib_path=/usr/lib/lib-crash
    if [ "\$LIB_CRASH_PATH" != "" ]
    then
        lib_path="\$LIB_CRASH_PATH"
    fi

    if [ ! -d "\$lib_path" ]
    then
        echo "[lib-crash] install failed: lib-crash not found '\$lib_path'"
        return 1
    fi

    if [ -d "\$lib_path/\$lib" ]
    then
        echo "[lib-crash] install failed: lib installed already '\$lib_path/\$lib'"
        return 1
    fi

    git clone --recursive "\$repo" "\$lib_path/\$lib"
}
export -f crash_include
export -f crash_install
export LIB_CRASH_VERSION="$current_version"
# lib-crash end
EOF

arg_method=${1:-local}
arg_path=${2:-/usr/lib/lib-crash}
bash_file=""
bash_file_root=""
if [ -f /etc/bash.bashrc ] && [ -f /root/.bashrc ] # debian
then
    bash_file=/etc/bash.bashrc
    bash_file_root=/root/.bashrc
elif [ -f /etc/bashrc ] && [ -f /root/.bashrc ] # redhat
then
    bash_file=/etc/bashrc
    bash_file_root=/root/.bashrc
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
    if grep -q "# lib-crash start" "$bash_file"
    then
        return
    fi
    # insert at start of file before any return
    echo "$crash_include" | cat - "$bash_file" > /tmp/lib-crash-bashrc || exit 1
    mv /tmp/lib-crash-bashrc "$bash_file" || exit 1
    echo "$crash_include" | cat - "$bash_file_root" > /tmp/lib-crash-bashrc-root || exit 1
    mv /tmp/lib-crash-bashrc-root "$bash_file_root" || exit 1
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
    sed '/# lib-crash start/,/# lib-crash end/d' "$bash_file" > /tmp/lib-crash-bashrc || exit 1
    cp /tmp/lib-crash-bashrc "$bash_file" || exit 1
    sed '/# lib-crash start/,/# lib-crash end/d' "$bash_file_root" > /tmp/lib-crash-bashrc-root || exit 1
    cp /tmp/lib-crash-bashrc-root "$bash_file_root" || exit 1
    log "successfully uninstalled lib-crash"
else
    log "invalid argument '$arg_method' visit help page"
    echo "$0 --help"
    exit 1
fi

