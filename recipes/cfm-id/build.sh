#!/bin/bash

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

mkdir build
cd build

cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX -DLPSOLVE_INCLUDE_DIR="${PREFIX}/include" -DLPSOLVE_LIBRARY_DIR="${PREFIX}/lib" -DBoost_INCLUDE_DIR="${PREFIX}/include" -DBOOST_LIBRARYDIR="${PREFIX}/lib"

make
make install

cp cmfid ${PREFIX}/bin/cmfid
