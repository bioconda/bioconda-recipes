#!/bin/bash

set -e

cd src

cmake ${CMAKE_ARGS} -DCMAKE_BUILD_TYPE=Release .
make -j${CPU_COUNT}

mkdir -p ${PREFIX}/bin
cp FALCON2 ${PREFIX}/bin/falcon2