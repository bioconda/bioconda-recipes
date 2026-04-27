#!/bin/bash
set -ex


git submodule update --init --recursive

mkdir build
cd build

cmake .. \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DMPI_C_COMPILER=$PREFIX/bin/mpicc \
  -DMPI_CXX_COMPILER=$PREFIX/bin/mpicxx

make -j${CPU_COUNT}
make install