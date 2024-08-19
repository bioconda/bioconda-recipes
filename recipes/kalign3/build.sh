#!/bin/bash
set -xeo pipefail

mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} .. 
make -j ${CPU_COUNT}
make install
