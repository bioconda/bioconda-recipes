#!/bin/bash

mkdir -p build
cd build
cmake -DOVERRIDE_COMMIT_VERSION=d2d8fc1 -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_EXE_LINKER_FLAGS=-L${PREFIX}/lib ..
make VERBOSE=1 -j 8 maCMD

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib
cp maCMD $PREFIX/bin
cp libMA.so $PREFIX/lib/

