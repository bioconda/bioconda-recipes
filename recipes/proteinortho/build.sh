#!/bin/bash

export STATIC="FALSE"
if [ `uname` == Darwin ]; then
    export LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
#    export STATIC="TRUE"
fi

make clean
make CC=$CC CXX=$CXX STATIC=$STATIC all -j${CPU_COUNT}
mkdir -p $PREFIX/bin
make install PREFIX=$PREFIX/bin/
