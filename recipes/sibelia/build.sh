#!/bin/bash

cd build
cmake ../src -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_CXX_COMPILER=$CXX -DCMAKE_CC_COMPILER=$CC
make
make install
