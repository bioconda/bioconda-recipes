#!/bin/bash

set -e -x -o pipefail

binaries="\
bmfilter \
bmtool \
extract_fullseq \
bmtagger.sh \
"

mkdir -p $PREFIX/bin
#for i in $binaries; do cp $SRC_DIR/bmtagger/$i $PREFIX/bin/ && chmod +x $PREFIX/bin/$i; done

if [ "$(uname)" == "Darwin" ]; then
    echo "Platform: Mac"

    for i in $binaries; do cp $SRC_DIR/$i $PREFIX/bin/ && chmod +x $PREFIX/bin/$i; done

elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    echo "Platform: Linux"

    # cd to location of Makefile and source
    cd $SRC_DIR/
    make CC=$CC CXX=$CXX

    for i in $binaries; do cp $SRC_DIR/bmtagger/$i $PREFIX/bin/ && chmod +x $PREFIX/bin/$i; done
fi

chmod +x $PREFIX/bin/*
