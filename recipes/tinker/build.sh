#!/usr/bin/env bash

set -xe

cmake -S ./cmake/ -B build \
     -DCMAKE_INSTALL_PREFIX=${PREFIX} \
     -DFFTW3_LIBRARY_DIRS=${PREFIX}/lib \
     -DCMAKE_BUILD_TYPE=Release \
     -DFFTW_THREAD_TYPE=omp

cmake --build build --target install -j "${CPU_COUNT}" -v
