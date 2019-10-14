#!/bin/bash

if [[ $(uname) == "Darwin" ]]
then
    export CMAKE_CXX_FLAGS="-stdlib=libc++"
fi

make install CXX="${CXX} $CMAKE_CXX_FLAGS -I$PREFIX/include -L$PREFIX/lib" prefix=${PREFIX}
chmod +x ${PREFIX}/bin/*
