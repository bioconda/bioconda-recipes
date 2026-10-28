#!/bin/bash

set -e -x -o pipefail

binaries="\
bmfilter \
bmtool \
extract_fullseq \
bmtagger.sh \
"

mkdir -p $PREFIX/bin

if [ "$(uname)" == "Darwin" ]; then
    echo "Platform: Mac"
    for i in $binaries; do cp $SRC_DIR/$i $PREFIX/bin/ && chmod +x $PREFIX/bin/$i; done
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    echo "Platform: Linux"
    #make CC=$CC CXX=$CXX
    for file in general bmtagger; do
        make -C $file CXX=${CXX} CC=${CC}
    done
    for i in $binaries; do cp $SRC_DIR/bmtagger/$i $PREFIX/bin/ && chmod +x $PREFIX/bin/$i; done
fi

chmod +x $PREFIX/bin/*
