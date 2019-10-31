#!/bin/bash

logger_dbg=1

Reset='\033[0m'
Red='\033[0;31m'
Green='\033[0;32m'
Yellow='\033[0;33m'
Purple='\033[0;35m'

function err() {
    echo -e "[${Red}error${Reset}] $1"
}

function log() {
    echo -e "[${Yellow}*${Reset}] $1"
}

function wrn() {
    echo -e "[${Yellow}!${Reset}] $1"
}

function suc() {
    echo -e "[${Green}+${Reset}] $1"
}

function dbg() {
    if [ "$logger_dbg" -eq 0 ]
    then
        return;
    fi
    echo -e "[${Purple}dbg${Reset}] $1"
}

