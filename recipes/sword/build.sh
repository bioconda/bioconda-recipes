#!/bin/bash

mkdir -p $PREFIX/bin
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${PREFIX} -Dsword_optimize_for_portability=ON ..
make
make install
