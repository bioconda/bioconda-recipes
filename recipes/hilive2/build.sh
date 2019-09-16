#!/bin/bash

mkdir build
cd build

cmake -E env CXXFLAGS="-pthread" cmake -DCMAKE_BUILD_TYPE=Release -DSEQAN_INCLUDE_PATH="${CONDA_DEFAULT_ENV}/include/" -DCMAKE_PREFIX_PATH="${CONDA_DEFAULT_ENV}/share/cmake/seqan" -DCONDA=ON ..

make

mkdir -p ${PREFIX}/bin
cp ${SRC_DIR}/hilive2/build/hilive ${PREFIX}/bin/
cp ${SRC_DIR}/hilive2/build/hilive-build ${PREFIX}/bin/
cp ${SRC_DIR}/hilive2/build/hilive-out ${PREFIX}/bin/

