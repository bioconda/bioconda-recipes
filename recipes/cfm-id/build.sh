#!/bin/bash

cd "source"
mkdir build
cd build

cmake .. -DLPSOLVE_INCLUDE_DIR="${PREFIX}/include" -DLPSOLVE_LIBRARY_DIR="${PREFIX}/include" -DBoost_INCLUDE_DIR="${PREFIX}/include"
make
make install

cp cmfid ${PREFIX}/bin/cmfid

