#!/bin/bash

current="$(pwd)"
if [[ $1 ]];then
    if [[ -d "$1" ]] ; then
        cd "$(readlink "$1")"
    else
        if [ -f "$1" ]; then
            cd "$(dirname "$(readlink "$1")")"
        else
            echo "Arg must be a directory"
        fi
    fi
fi

find . -name '*.blg' -type f -delete
find . -name '*.bbl' -type f -delete
find . -name '*.aux' -type f -delete
find . -name '*.log' -type f -delete
find . -name '*.thm' -type f -delete
find . -name '*.out' -type f -delete
find . -name '*.spl' -type f -delete
find . -name '*.gz' -type f -delete
find . -name '*.toc' -type f -delete
find . -name '*.lof' -type f -delete
find . -name '*.lot' -type f -delete
find . -name '*.run.xml' -type f -delete
find . -name '*-blx.bib' -type f -delete
find . -name '*.maf' -type f -delete
find . -name '*.mtc' -type f -delete
find . -name '*.mtc0' -type f -delete
find . -name '*.mtc1' -type f -delete
find . -name '*.mtc2' -type f -delete
find . -name '*.mtc3' -type f -delete
find . -name '*.mtc4' -type f -delete
find . -name '*.mtc5' -type f -delete
find . -name '*.mtc6' -type f -delete
find . -name '*.mtc7' -type f -delete
find . -name '*.mtc8' -type f -delete
find . -name '*.mtc9' -type f -delete
find . -name '*.bcf' -type f -delete