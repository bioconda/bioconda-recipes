#!/bin/bash

# 正确方式
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "${PREFIX}/bin"

case $(uname -m) in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	;;
    x86_64)
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
	;;
esac

cat makefile | sed 's/clang/$(CC)/g' | sed 's/=/+=/g'> tmp_makefile
rm -f makefile
mv tmp_makefile Makefile

case $(uname -m) in
    aarch64|arm64)
	sed -i 's/-msse4.2//g' Makefile
    sed -i 's/-march=[^ ]*sse4.2[^ ]*//g' Makefile
	;;
esac

if [ "$(uname -s)" == "Darwin" ]; then
    # for parallelism build with multicore support
    # see https://github.com/debbiemarkslab/plmc#compilation
    # make all-mac-openmp
    make all-mac-openmp CC="${CC}" CLANGFLAG="${CFLAGS} -lm -Wall -Ofast" -j"${CPU_COUNT}"
    install -v -m 0755 bin/plmc "${PREFIX}/bin"
else
    # see https://github.com/debbiemarkslab/plmc/issues/12
    sed -i.bak '1 i\#include <sys/time.h>' ./src/include/plm.h
    make all-openmp CC="${CC}" GCCFLAGS="${CFLAGS} -std=c99 -lm -O3" -j"${CPU_COUNT}"
    install -v -m 0755 bin/plmc "${PREFIX}/bin"
fi
