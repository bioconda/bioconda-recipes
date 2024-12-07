#!/bin/bash
set -xe
make CXX="${CXX}" INCLUDES="-I$PREFIX/include" CFLAGS+="${CFLAGS} -g -Wall -O2 -L$PREFIX/lib"
chmod 777 ./bin/VirDiG
mkdir -p ${PREFIX}/bin
cp -f ./bin/VirDiG ${PREFIX}/bin