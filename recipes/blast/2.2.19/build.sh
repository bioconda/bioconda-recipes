#!/bin/bash

set -e -x -o pipefail

mkdir -p $PREFIX/bin

if [ "$(uname)" == "Darwin" ]; then
    echo "Platform: Mac"

    # export CFLAGS='-O3'
    # export CXXFLAGS='-O3'

    cp $SRC_DIR/bin/* $PREFIX/bin

elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    echo "Platform: Linux"
    
    # Blast binaries require libpcre.so.0, but pcre packages comes with libpcre.so.1
    LIBPCRE_TRUE_PATH="$(readlink --canonicalize ${PREFIX}/lib/libpcre.so.1)"
    ln -s $LIBPCRE_TRUE_PATH ${PREFIX}/lib/libpcre.so.0
    
    cp $SRC_DIR/bin/* $PREFIX/bin/
fi

chmod +x $PREFIX/bin/*