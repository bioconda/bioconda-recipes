#!/bin/bash

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DSEQAN_BUILD_SYSTEM=APP:mason2 -DCMAKE_INSTALL_PREFIX=${PREFIX}
cmake --build build/ -j ${CPU_COUNT}
cmake --install build/
