#!/bin/bash
cd build
cmake ../src -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_CXX_COMPILER=${CXX} -DCMAKE_C_COMPILER=${CC}
make CC=${CC} CXX=${CXX}
make install
