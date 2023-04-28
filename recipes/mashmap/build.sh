#!/bin/bash


export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export CPATH=${PREFIX}/include

cmake -H. -B${PREFIX} -DCMAKE_BUILD_TYPE=Release -DCMAKE_VERBOSE_MAKEFILE=1 -DOPTIMIZE_FOR_NATIVE=0
cmake --build ${PREFIX}
