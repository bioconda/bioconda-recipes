#!/bin/bash
mkdir -p "$PREFIX/bin"
if [ "$(uname)" == "Darwin" ]; then
    cp bedJoinTabOffset "$PREFIX/bin"
else
    cp kent/src/utils/bedJoinTabOffset "$PREFIX/bin"
fi
chmod +x "$PREFIX/bin/bedJoinTabOffset"
