#!/bin/bash

# 正确方式
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

mkdir -p "${PREFIX}/bin"

case $(uname -m) in
    aarch64|arm64)
	sed -i.bak 's|-msse4.2||' makefile
	;;
esac

sed -i.bak 's|clang|$(CC)|' makefile
sed -i.bak 's|gcc|$(CC)|' makefile
rm -rf *.bak

if [ "$(uname -s)" == "Darwin" ]; then
    # for parallelism build with multicore support
    # see https://github.com/debbiemarkslab/plmc#compilation
    # make all-mac-openmp
    make all-mac-openmp CC="${CC}" CLANGFLAG="${CFLAGS} -lm -Wall -Ofast" LIBOMP_PREFIX="${PREFIX}" -j"${CPU_COUNT}"
    install -v -m 0755 bin/plmc "${PREFIX}/bin"
else
    # see https://github.com/debbiemarkslab/plmc/issues/12
    sed -i.bak '1 i\#include <sys/time.h>' ./src/include/plm.h
    make all-openmp CC="${CC}" GCCFLAGS="${CFLAGS} -std=c99 -lm -O3" -j"${CPU_COUNT}"
    install -v -m 0755 bin/plmc "${PREFIX}/bin"
fi
