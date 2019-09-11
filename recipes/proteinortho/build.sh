#!/bin/bash

if [ `uname` == Darwin ]; then
    export LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
fi

make clean
make CC=$CC CXX=$CXX V=1 all -j${CPU_COUNT}
mkdir -p $PREFIX/bin
make install PREFIX=$PREFIX/bin/
