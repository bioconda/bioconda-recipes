#!/bin/bash
set -ex

export C_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

mkdir -p "${PREFIX}/bin"

# clear out pre-built objects and executables
cd src

make CC="${CC}" clobber -j"${CPU_COUNT}"

make CC="${CC}" all -j"${CPU_COUNT}"

make install TOP="${PREFIX}/bin"
