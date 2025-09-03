#!/bin/bash

# 正确方式
export CFLAGS="-O2 -march=armv8-a"
export CXXFLAGS="-O2 -march=armv8-a"


cat makefile | sed 's/clang/$(CC)/g' | sed 's/=/+=/g'> tmp_makefile
rm makefile
mv tmp_makefile Makefile
sed -i 's/-msse4.2//g' Makefile
sed -i 's/-march=[^ ]*sse4.2[^ ]*//g' Makefile

mkdir -p "${PREFIX}/bin"

if [ "$(uname)" == "Darwin" ]; then
    # for parallelism build with multicore support
    # see https://github.com/debbiemarkslab/plmc#compilation
    # make all-mac-openmp
    make all-mac CC="${CC}" CLANGFLAG="${CFLAGS} -lm -Wall -Ofast"
    cp ./bin/plmc "${PREFIX}/bin/plmc"
else
    # see https://github.com/debbiemarkslab/plmc/issues/12
    sed  -i.bak '1 i\#include <sys/time.h>' ./src/include/plm.h
    make all-openmp CC="${CC}" GCCFLAGS="${CFLAGS} -std=c99 -lm -O3"
    cp ./bin/plmc "${PREFIX}/bin/plmc"
fi
