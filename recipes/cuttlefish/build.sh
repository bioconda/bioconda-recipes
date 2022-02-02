#!/bin/bash

mkdir build
cd build

cmake -DINSTANCE_COUNT=64 -DCMAKE_INSTALL_PREFIX=${PREFIX} ..
make install
