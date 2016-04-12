#!/bin/bash

set -e -x -o pipefail

mkdir -p $PREFIX/bin

if [ "$(uname)" == "Darwin" ]; then
    echo "Platform: Mac"

    # export CFLAGS='-O3'
    # export CXXFLAGS='-O3'

    cp $SRC_DIR/bin/rmblastn $PREFIX/bin

elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    echo "Platform: Linux"

    cd $SRC_DIR/c++
    ./configure --prefix=$PREFIX --with-mt --without-debug

    make -j4

    cp $SRC_DIR/c++/GCC*-ReleaseMT*/bin/rmblastn $PREFIX/bin
fi

chmod +x $PREFIX/bin/*
