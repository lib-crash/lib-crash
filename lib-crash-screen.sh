#!/bin/bash

height="$1"

top=/tmp/lib-crash-top
bottom=/tmp/lib-crash-bottom

function hr() {
    local i
    local cols
    local str=""
    cols="$(tput cols)"
    for ((i=0;i<cols;i++))
    do
        str+='-'
    done
    echo "$str"
}

while true
do
    clear
    lines="$(tput lines)"
    lines_top=$((lines - height))
    lines_bottom=$height
    if [ -f "$top" ]
    then
        tail -n"$lines_top" "$top"
        buf=""
        l="$(tail -n"$lines_top" "$top" | wc -l)"
        for ((l;l<lines_top;l++))
        do
            buf+="\\n"
        done
        printf "%s" "$buf"
    fi
    hr
    if [ -f "$bottom" ]
    then
        tail -n"$lines_bottom" "$bottom"
        # buf=""
        # l="$(tail -n"$lines_bottom" "$bottom" | wc -l)"
        # for ((l;l<lines_bottom;l++))
        # do
        #   buf+="\\n"
        # done
        # printf "%s" "$buf"
    fi
    sleep 0.2
done

