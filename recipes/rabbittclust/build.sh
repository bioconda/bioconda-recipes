#!/bin/bash
set -euxo pipefail

export CXX=g++
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

# make rabbitSketch library
mkdir -p RabbitSketch/build
cd RabbitSketch/build
cmake ../ -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_CXX_COMPILER=${CXX} -DCMAKE_CXX_FLAGS="$CXXFLAGS" -DCXXAPI=ON
make
make install
cd ../../

# make rabbitFX library
mkdir -p RabbitFX/build
cd RabbitFX/build
cmake ../ -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_CXX_COMPILER=${CXX} -DCMAKE_CXX_FLAGS="$CXXFLAGS" -DCXXAPI=ON
make
make install
cd ../../

# compile the clust-greedy
mkdir -p build
cd build
cmake ../ -DUSE_RABBITFX=ON -DUSE_GREEDY=ON -DCMAKE_INSTALL_PREFIX=$PREFIX/bin -DCMAKE_CXX_COMPILER=${CXX} -DCMAKE_CXX_FLAGS="$CXXFLAGS"
make
make install

# compile the clust-mst
cmake ../ -DUSE_RABBITFX=ON -DUSE_GREEDY=OFF -DCMAKE_INSTALL_PREFIX=$PREFIX/bin -DCMAKE_CXX_COMPILER=${CXX} -DCMAKE_CXX_FLAGS="$CXXFLAGS"
make
make install
