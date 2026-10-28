#!/bin/bash -euo

mkdir -p "$PREFIX/bin"

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -Wall -O3 -Wno-unused-variable -Wno-unused-function -Wno-misleading-indentation -DUSE_SIMDE -DSIMDE_ENABLE_NATIVE_ALIASES -I${PREFIX}/include -L${PREFIX}/lib"

OS=$(uname -s)
ARCH=$(uname -m)

pushd abPOA
make libabpoa INCLUDE="-I$PREFIX/include" CFLAGS="$CFLAGS"
popd

make CFLAGS="${CFLAGS}" -j"${CPU_COUNT}"

install -v -m 0755 bin/TideHunter "$PREFIX/bin"
