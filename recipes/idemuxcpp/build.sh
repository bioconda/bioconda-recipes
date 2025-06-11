#!/bin/sh

set -xe

export CXXFLAGS="-I${PREFIX}/include/bamtools ${CXXFLAGS}"
export LDFLAGS="-L${PREFIX}/lib/ -lbamtools ${LDFLAGS}"
./configure --enable-tests --prefix="${PREFIX}"
make -j ${CPU_COUNT}
make install
make check
