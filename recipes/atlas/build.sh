#!/bin/bash

cmake . -GNinja \
      -DCONDA=ON \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_COMPILER=${CXX} \
      -DCMAKE_LIBRARY_PATH=${CONDA_PREFIX}/lib \
      -DCMAKE_INCLUDE_PATH=${CONDA_PREFIX}/include

ninja || exit 1

mkdir -p ${PREFIX}/bin
cp atlas ${PREFIX}/bin || exit 1
chmod +x ${PREFIX}/bin/atlas
