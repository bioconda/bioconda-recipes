#!/bin/bash

mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX=${PREFIX} -DSTATIC=OFF -DCMAKE_EXE_LINKER_FLAGS=-L${PREFIX}/lib ..
make VERBOSE=1

mkdir -p $PREFIX/bin
cp ../bin/sniffles-core-${PKG_VERSION}/sniffles* $PREFIX/bin/

