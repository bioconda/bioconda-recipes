#!/bin/bash

cat makefile | sed 's/clang/$(CC)/g' | sed 's/=/+=/g'> tmp_makefile
rm makefile
mv tmp_makefile Makefile

mkdir -p "${PREFIX}/bin"

if [ "$(uname)" == "Darwin" ]; then
    # for parallelism build with multicore support
    # see https://github.com/debbiemarkslab/plmc#compilation
    # make all-mac-openmp
    make all-mac CC="${CC}" CLANGFLAG="${CFLAGS} -lm -Wall -Ofast -msse4.2"
    cp ./bin/plmc "${PREFIX}/bin/plmc"
else
    # see https://github.com/debbiemarkslab/plmc/issues/12
    sed  -i.bak '1 i\#include <sys/time.h>' ./src/include/plm.h
    make all-openmp CC="${CC}" GCCFLAGS="${CFLAGS} -std=c99 -lm -O3 -msse4.2"
    cp ./bin/plmc "${PREFIX}/bin/plmc"
fi
