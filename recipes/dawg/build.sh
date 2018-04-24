#!/bin/bash

# avoid CMake Error "In-source builds not allowed."
mkdir cmake_build_dir
cd cmake_build_dir

cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX ..
make
make install
