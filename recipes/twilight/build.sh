#!/bin/bash

# Build
mkdir -p "${PREFIX}/bin"
mkdir -p build
cp ${RECIPE_DIR}/CMakeLists.txt $SRC_DIR/CMakeLists.txt
cd build || exit 1
# wget https://github.com/oneapi-src/oneTBB/archive/2019_U9.tar.gz
# tar -xvzf 2019_U9.tar.gz
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_PREFIX_PATH=$PREFIX
# cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DTBB_DIR=$SRC_DIR/build/oneTBB-2019_U9 -DCMAKE_PREFIX_PATH=$SRC_DIR/build/oneTBB-2019_U9/cmake ..
make -j
cp twilight ${PREFIX}/bin
twilight --help