#!/bin/bash

height=10
id="$(od -x /dev/urandom | head -1 | awk '{OFS="-"; print $2$3,$4,$5,$6,$7$8$9}')"
top=/tmp/lib-crash-top
bottom=/tmp/lib-crash-bottom
split_running=0

function split_start() {
    height="${1:-10}"
    split_running=1
    ./lib-crash-screen.sh "$height" --id="$id" &
    # clear split files
    : >"$top"
    : >"$bottom"
    # save stdout to fd 6
    exec 6>&1
    # redirect stdout to file
    exec 1<> "$top"
}

function split_stop() {
    if [ "$split_running" != "1" ]
    then
        return
    fi
    split_running=0
    # close file descriptor
    exec 1>&-
    # restore stdout from fd 6
    exec 1>&6
    pkill -f "./lib-crash-screen.sh $height --id=$id"
}

function split_kill() {
    split_stop
    exit 1
}

function split_log() {
    echo "$1" >> "$bottom"
}

function split_clear() {
    local i
    local height
    height="$(tput lines)"
    clear
    for ((i=0;i<height;i++))
    do
        echo ""
    done
}

trap split_kill EXIT INT QUIT TERM

