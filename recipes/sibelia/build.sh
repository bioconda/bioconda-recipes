#!/bin/bash
cd build
# this was recommended by https://github.com/ContinuumIO/anaconda-issues/issues/483
cmake ../src -DCMAKE_INSTALL_PREFIX=${PREFIX} 
make
make install
