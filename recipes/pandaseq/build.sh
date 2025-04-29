#!/bin/bash

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
