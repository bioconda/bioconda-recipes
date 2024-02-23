#!/bin/bash


export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export CPATH=${PREFIX}/include

# if [[ ${HOST} =~ .*darwin.* ]]; then
#   export MACOSX_DEPLOYMENT_TARGET=10.15  # Required to use std::filesystem
# fi  

cmake -H. -B${PREFIX} -DCMAKE_BUILD_TYPE=Release -DCMAKE_VERBOSE_MAKEFILE=1 -DOPTIMIZE_FOR_NATIVE=0 -DUSE_HTSLIB=1
cmake --build ${PREFIX}
