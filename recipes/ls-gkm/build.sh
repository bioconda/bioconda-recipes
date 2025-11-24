#!/bin/bash

mkdir -p ${PREFIX}/bin

sed -i.bak 's|-lpthread|-pthread|' src/Makefile
rm -rf src/*.bak

cd src

make CXX="${CXX}" -j"${CPU_COUNT}"
make install

install -v -m 0755 ../bin/* gkmtrain-svr "${PREFIX}/bin"
