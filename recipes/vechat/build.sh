#!/bin/bash

# mkdir -p $PREFIX/bin
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${PREFIX}  -Dspoa_optimize_for_portability=ON ..
make
make install
ln -fs $PWD/scripts/vechat ${PREFIX}/bin/vechat

