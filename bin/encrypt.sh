#!/usr/bin/env bash

if [ -z "$1" ]; then
    echo "Please specify GPG key as the first argument"
    exit
fi

KEY_ID=$1

function encrypt {
    gpg --encrypt --batch --yes -r $KEY_ID $1
    if [ ! "$?" -eq "0" ]; then
        exit
    fi
}

FILES=$(ls ssh/oracle* | grep -v \.gpg)
for f in $FILES; do
    encrypt $f
done

if [ -f ca.tar.gz ]; then
    rm ca.tar.gz
fi

tar cvzf ca.tar.gz ca
encrypt ca.tar.gz
