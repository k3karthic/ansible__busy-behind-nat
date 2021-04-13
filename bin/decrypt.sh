#!/usr/bin/env bash

function decrypt {
    gpg --decrypt --batch --yes --output "$1" "$1.gpg"
    if [ ! "$?" -eq "0" ]; then
        exit
    fi
}

FILES=$(ls ssh/oracle*.gpg)
for f in $FILES; do
    decrypt $( echo $f | sed 's/\.gpg//' )
done
