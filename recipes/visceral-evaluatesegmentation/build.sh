#!/bin/bash

cd "source"
mkdir build
cd build

cmake \
    -D CMAKE_INSTALL_PREFIX=${PREFIX} \
    -D CMAKE_INSTALL_RPATH:STRING=${PREFIX}/lib \
    -D CMAKE_BUILD_TYPE=Release \
    -D ITK_DIR=${PREFIX} \
    ..

make -j4
cp EvaluateSegmentation ${PREFIX}/bin/EvaluateSegmentation
