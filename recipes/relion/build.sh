#!/usr/bin/env bash

set -xe

mkdir build
cd build
cmake .. ${CMAKE_ARGS} -DCMAKE_BUILD_TYPE=Release -DGUI=OFF -DCMAKE_INSTALL_PREFIX=$PREFIX
make -j"${CPU_COUNT}"
make install
