#!/bin/bash

set -e -x -o pipefail

if [ "$(uname)" == "Darwin" ]; then
    echo "Platform: Mac"

    # export CFLAGS='-O3'
    # export CXXFLAGS='-O3'

    mkdir -p $PREFIX/bin
    cp $SRC_DIR/bin/* $PREFIX/bin
    chmod +x $PREFIX/bin/*

elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    echo "Platform: Linux"

    cd $SRC_DIR/c++
    ./configure --prefix=$PREFIX

    make

    mkdir -p $PREFIX/bin
    cp $SRC_DIR/c++/ReleaseMT/bin/* $PREFIX/bin
    chmod +x $PREFIX/bin/*
fi

