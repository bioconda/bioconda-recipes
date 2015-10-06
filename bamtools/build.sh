#!/bin/bash
mkdir -p build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} ..
make install
