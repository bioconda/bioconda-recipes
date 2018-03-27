#!/bin/bash

# CXX=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-g++ 
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DBOOST_ROOT=$PREFIX -DBoost_NO_SYSTEM_PATHS=ON .
VERBOSE=TRUE make
make install
