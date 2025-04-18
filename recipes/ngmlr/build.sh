#!/bin/bash

set -xe

mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX=${PREFIX} -DSTATIC=OFF -DCMAKE_EXE_LINKER_FLAGS=-L${PREFIX}/lib ..
make VERBOSE=1 -j ${CPU_COUNT}

mkdir -p $PREFIX/bin
cp ../bin/ngmlr-${PKG_VERSION}/ngmlr $PREFIX/bin/

