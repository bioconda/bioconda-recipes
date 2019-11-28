#!/bin/sh
set -x -e

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"

export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

if [ "$build_os" == "Darwin" ]; then
    export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
    export ARCHFLAGS="-Wno-error=unused-command-line-argument-hard-error-in-future"
    export CFLAGS=-Qunused-arguments
    export CPPFLAGS="${CPPFLAGS} -Qunused-arguments"
else
    export LD_LIBRARY_PATH="${PREFIX}/lib"
fi

make
make all

cp finalFusion ${PREFIX}/bin
