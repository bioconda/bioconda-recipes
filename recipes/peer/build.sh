#!/bin/bash

set -eux

mkdir build
cd build
cmake ../ -DBUILD_PYTHON_PACKAGE=OFF -DBUILD_PEERTOOL=ON
make -j $CPU_COUNT
mkdir -p "${PREFIX}/bin"
install src/peertool "${PREFIX}/bin"
