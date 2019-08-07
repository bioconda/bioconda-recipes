#!/bin/bash
set -eu -o pipefail

CXXFLAGS="${CXXFLAGS} -fPIC"

sed -i '1s/.*/CC=${CC}/' SeqLib/fermi-lite/Makefile

./configure
make CC=${CC} CXX=${CXX} CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}"
make install

mkdir -p ${PREFIX}/bin
cp bin/svaba ${PREFIX}/bin/
