#!/bin/bash
set -xe

make -j"${CPU_COUNT}" CXX="${CXX}" INCLUDES="-I$PREFIX/include" CFLAGS+="${CFLAGS} -g -Wall -O2 -L$PREFIX/lib"
chmod 755 ./bin/fc-virus
mkdir -p ${PREFIX}/bin
cp -f ./bin/fc-virus ${PREFIX}/bin
