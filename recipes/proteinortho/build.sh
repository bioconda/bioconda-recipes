#!/bin/bash

if [ `uname` == Darwin ]; then
    export LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
fi

make clean
ls -l $PREFIX/lib
make CC=$CC CXX=$CXX SHELL="sh -x"
mkdir -p $PREFIX/bin
make install PREFIX=$PREFIX/bin/
