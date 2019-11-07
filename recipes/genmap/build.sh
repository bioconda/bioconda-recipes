#!/bin/bash

git submodule update --init --recursive
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=Release -DGENMAP_NATIVE_BUILD=OFF
make
make install
