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

    make > make.log 2>&1

    echo "Last 1000 lines of make log"
    tail -1000 make.log

    cp $SRC_DIR/c++/GCC*-ReleaseMT*/bin/rmblastn $PREFIX/bin
fi

chmod +x $PREFIX/bin/*

# if we only have libbz2.so.1.0, make a symlink to libbz2.so.1
if [[ ! -e $PREFIX/lib/libbz2.so.1 && -e $PREFIX/lib/libbz2.so.1.0 ]] ; then
  ln -s $PREFIX/lib/libbz2.so.1.0 $PREFIX/lib/libbz2.so.1
fi
