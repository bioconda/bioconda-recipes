#!/bin/bash

cd "source"
mkdir build
cd build

export ITK_DIR=${PREFIX}

cmake \
    -D CMAKE_INSTALL_PREFIX=${PREFIX} \
    -D CMAKE_INSTALL_RPATH:STRING=${PREFIX}/lib \
    -D CMAKE_BUILD_TYPE=Release \
    ..

make -j4
cp EvaluateSegmentation ${PREFIX}/bin/EvaluateSegmentation
