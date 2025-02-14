#!/bin/bash

cmake -S . -B build -DSEQAN_BUILD_SYSTEM=APP:mason2 -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_CXX_FLAGS=-D_LIBCPP_ENABLE_CXX17_REMOVED_UNARY_BINARY_FUNCTION
cmake --build build/ -j ${CPU_COUNT}
cmake --install build/
