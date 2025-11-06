#!/bin/bash

export M4="${BUILD_PREFIX}/bin/m4"
export C_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
if [[ "$(uname)" == "Darwin" ]]; then
  export CFLAGS="${CFLAGS} -Wno-error=implicit-function-declaration"
fi

mkdir -p $PREFIX/bin

./autogen.sh
./configure --prefix=$PREFIX
make
make install
