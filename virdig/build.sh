#!/bin/bash
set -xe
make -j"${CPU_COUNT}" CXX="${CXX}" INCLUDES="-I$PREFIX/include" CFLAGS+="${CFLAGS} -g -Wall -O2 -L$PREFIX/lib"
