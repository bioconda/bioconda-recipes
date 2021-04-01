#!/bin/bash

cd probmask/ || true
cd trunk/

./autogen.sh
./configure --prefix=${PREFIX}
export CFLAGS="${CFLAGS} -fcommon"
export CXXFLAGS="${CXXFLAGS} -fcommon"
export CC="${CC} -fcommon"
export CXX="${CXX} -fcommon"

make
make install
