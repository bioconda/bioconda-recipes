#!/bin/bash

mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE=RELEASE -DWITH_DB=OFF -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_EXE_LINKER_FLAGS=-L${PREFIX}/lib ..
make VERBOSE=1 -j 8 maCMD

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib
cp maCMD $PREFIX/bin
cp lib*.so $PREFIX/lib/
