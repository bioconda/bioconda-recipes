#!/bin/bash
cd build
# this was recommended by https://github.com/ContinuumIO/anaconda-issues/issues/483
cmake ../src -DCMAKE_C_COMPILER=${PREFIX}/bin/gcc -DCMAKE_CXX_COMPILER=${PREFIX}/bin/g++ -DCMAKE_INSTALL_PREFIX=${PREFIX} 
make
make install
