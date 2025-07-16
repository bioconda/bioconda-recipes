#! /bin/sh

mkdir -p $PREFIX/bin
mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE=RELEASE \
    -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX \
    ..
make VERBOSE=1
cp moss $PREFIX/bin
