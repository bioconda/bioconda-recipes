#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

mkdir -p "${PREFIX}/bin"

tar -xvzf squid.tar.gz

cd squid-1.9g

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* .

./configure --prefix="${PREFIX}"

make clean

make
make install

cd ..

make CC="${CC}" CFLAGS="${CFLAGS}" INCLUDE="-I. -I${PREFIX}/include" LIBS="${LDFLAGS} -lm -lsquid"

install -v -m 0755 randfold "${PREFIX}/bin"
