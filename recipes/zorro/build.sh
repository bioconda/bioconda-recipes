#!/bin/bash

cd probmask/ || true
cd trunk/

export CFLAGS="${CFLAGS} -fcommon"
export CXXFLAGS="${CXXFLAGS} -fcommon"
export CC="${CC} -fcommon"
export CXX="${CXX} -fcommon"
./autogen.sh
./configure --prefix=${PREFIX}

make
make install
