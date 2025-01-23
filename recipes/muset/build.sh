#!/bin/bash
set -e
set -x

mkdir -p ${PREFIX}/bin

mkdir build-conda
cd build-conda

cmake .. \
    -DCONDA_BUILD=ON \
    -Dexternal_dir=${SRC_DIR}/external \
    -Dexternal_bindir=${PWD}/external \
    -Dcmake_path=${SRC_DIR}/cmake

make -j${CPU_COUNT}
cd ..

cp ./bin/kmat_tools ${PREFIX}/bin
cp ./bin/muset ${PREFIX}/bin
cp ./bin/muset_pa ${PREFIX}/bin