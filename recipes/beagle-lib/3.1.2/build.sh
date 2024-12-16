#!/bin/bash

set -xe

export INCLUDES="-I{PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

./autogen.sh
./configure --prefix=${PREFIX} --with-jdk=${PREFIX} --disable-march-native
make -j ${CPU_COUNT}
make install
