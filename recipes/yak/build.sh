#!/bin/bash -ex

mkdir -p ${PREFIX}/bin

make INCLUDES="-I${PREFIX}/include" CFLAGS="${CFLAGS} -g -Wall -O2 -L${PREFIX}/lib"
cp -rf yak ${PREFIX}/bin
chmod 755 ${PREFIX}/bin/yak
