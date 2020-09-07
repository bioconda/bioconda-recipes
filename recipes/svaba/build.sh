#!/bin/bash
set -eu -o pipefail

sed -i.bak "s/-llzma -lbz2 -lz/-llzma -lbz2 -lz -pthread/g" src/svaba/Makefile.in
./configure
make CC=${CC} CXX=${CXX} CFLAGS="${CFLAGS} -L${PREFIX}/lib" CXXFLAGS="${CXXFLAGS} -UNDEBUG -L${PREFIX}/lib" LDFLAGS="${LDFLAGS}"
make install

mkdir -p ${PREFIX}/bin
cp bin/svaba ${PREFIX}/bin/
