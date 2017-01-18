#!/bin/bash

set -e -x -o pipefail

mkdir -p $PREFIX/bin/

if [ "$(uname)" == "Darwin" ]; then
    echo "Platform: Mac"

    cp $SRC_DIR/bin/* $PREFIX/bin/

elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    echo "Platform: Linux"

    cd $SRC_DIR/c++/
    ./configure --prefix=$PREFIX

    make -j${CPU_COUNT}

    cp $SRC_DIR/c++/ReleaseMT/bin/* $PREFIX/bin/
fi

chmod +x $PREFIX/bin/*
