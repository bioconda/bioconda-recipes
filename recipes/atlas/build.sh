#!/bin/bash

mkdir -p build
cd build
 cmake .. -GNinja -DCONDA=ON -DCMAKE_CXX_COMPILER=${CXX} -DCMAKE_LIBRARY_PATH=${CONDA_PREFIX}/lib -DCMAKE_INCLUDE_PATH=${CONDA_PREFIX}/include
ninja

mkdir -p ${PREFIX}/bin
cp atlas ${PREFIX}/bin
