#!/bin/bash

mkdir -p "${PREFIX}/bin"

gunzip squid.tar.gz
tar xf squid.tar
cd squid-1.9g

./configure --prefix=$PREFIX -q
make clean
make
make install

cd ..

make CC="${CC}" CFLAGS+=' -O3' LIBS="${LDFLAGS} -lm -lsquid"
cp randfold "${PREFIX}/bin/"
