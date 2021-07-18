#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: ./download-vscode-server.sh <commit>"
    exit
fi

COMMIT="$1"

wget -nv -O vscode-server-linux-x64-$COMMIT.tar.gz \
    https://update.code.visualstudio.com/commit:$COMMIT/server-linux-x64/stable
