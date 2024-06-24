#!/bin/bash

cmake -S . -B build -DSEQAN_BUILD_SYSTEM=APP:mason2 -DCMAKE_INSTALL_PREFIX=${PREFIX}
cmake --build build/
cmake --install build/
