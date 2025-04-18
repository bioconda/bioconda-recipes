#!/bin/sh

mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX="$PREFIX" -DCMAKE_BUILD_TYPE=Release ..
cmake --build .
mkdir -p $PREFIX/bin
install -m 755 install/bin/REViewer $PREFIX/bin
