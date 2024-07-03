#!/usr/bin/env bash

set -x

mkdir build
cd build

cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX}
make -j ${CPU_COUNT}

