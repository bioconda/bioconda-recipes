#!/bin/bash

cd build
cmake ../src -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_CXX_COMPILER=$CXX
make
make install
