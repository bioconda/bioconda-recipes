#!/bin/bash

mkdir -p $PREFIX/bin

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -I$PREFIX/include"
export STATIC="FALSE"

if [[ `uname` == Darwin ]]; then
    export LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
fi

make clean
make CC="${CC}" CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" STATIC="${STATIC}" all -j"${CPU_COUNT}"
make install PREFIX="${PREFIX}/bin/"
