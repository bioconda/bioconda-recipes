#!/bin/bash
set -eu

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

if [ $(uname) == "Darwin" ]; then
    export LDFLAGS="-headerpad_max_install_names ${LDFLAGS}"
fi

make CC=${CC} LIBRARY_PATH=${PREFIX}/lib prefix=${PREFIX}
make test
make install prefix=${PREFIX}
