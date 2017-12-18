#!/bin/bash

set -e -x -o pipefail

mkdir -p $PREFIX/bin

if [ "$(uname)" == "Darwin" ]; then
    echo "Platform: Mac"

    cp $SRC_DIR/bin/* $PREFIX/bin/

elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    echo "Platform: Linux"

    cd $SRC_DIR/c++/
    # --with-hard-runpath is needed otherwise BLAST programs would search
    # libraries first in the directories defined by the LD_LIBRARY_PATH
    # environment variable, instead of using the rpath specified by conda
    ./configure --prefix=$PREFIX --with-hard-runpath

    make -j${CPU_COUNT}

    cp $SRC_DIR/c++/ReleaseMT/bin/* $PREFIX/bin/
fi

chmod +x $PREFIX/bin/*
