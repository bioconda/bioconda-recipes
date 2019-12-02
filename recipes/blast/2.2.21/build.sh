#!/bin/bash

set -e -x -o pipefail
export LIBRARY_PATH=${PREFIX}/lib

mkdir -p $PREFIX/bin

if [ "$(uname)" == "Darwin" ]; then
    echo "Platform: Mac"
    cp $SRC_DIR/bin/* $PREFIX/bin
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    echo "Platform: Linux"
    cp $SRC_DIR/bin/* $PREFIX/bin/
    ln -s ${PREFIX}/lib/libbz2.so ${PREFIX}/lib/libbz2.so.1
fi
chmod +x $PREFIX/bin/*
