#!/bin/bash
set -eu

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH=${PREFIX}/lib
export LDFLAGS="-L$PREFIX/lib"

if [ $(uname) == "Darwin" ]; then
    export LDFLAGS="-headerpad_max_install_names $LDFLAGS"
fi
make CC=$CC
make test
mkdir -p ${PREFIX}/bin
cp bin/sambamba ${PREFIX}/bin/sambamba
