#!/bin/bash

if [ "$(uname)" != "Darwin" ]; then
    echo "Linux: static binary"
    cd $SRC_DIR
    mkdir -p $PREFIX/bin
    cp recontig $PREFIX/bin
else
    echo "MacOS: shared binary"

    cd $SRC_DIR
    mkdir -p $PREFIX/bin
    cp recontig $PREFIX/bin

fi