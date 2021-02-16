#!/bin/bash

mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_CXX_STANDARD_LIBRARIES="-ldl" ..
make -j "${CPU_COUNT}"
make install
