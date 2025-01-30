#!/bin/bash

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

make CC="${CC}" LINKER="${CC}" -j"${CPU_COUNT}"
mkdir -p $PREFIX/bin
install -v -m 0755 mdust $PREFIX/bin
