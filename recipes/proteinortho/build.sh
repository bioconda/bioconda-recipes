#!/bin/bash

if [ `uname` == Darwin ]; then
    export LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
fi

export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH=${PREFIX}/lib
make clean
make CC=$CC CXX=$CXX LDLIBS="-lgfortran" CXXLIBRARY="-L${PREFIX}/lib" all -j${CPU_COUNT}
mkdir -p $PREFIX/bin
make install PREFIX=$PREFIX/bin/
