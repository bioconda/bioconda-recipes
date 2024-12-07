#!/bin/bash
set -xe
make CXX="${CXX}" INCLUDES="-I$PREFIX/include" CFLAGS+="${CFLAGS} -g -Wall -O2 -L$PREFIX/lib"
chmod 777 ./bin/virdig
mkdir -p ${PREFIX}/bin
cp -f ./bin/virdig ${PREFIX}/bin
