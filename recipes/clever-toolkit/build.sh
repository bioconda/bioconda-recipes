#!/bin/bash

# TODO remove requirement for ABI=0 once conda-forge has switched to new compiler packages.
#CXX=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-g++ 
cmake -DCMAKE_CXX_FLAGS=-D_GLIBCXX_USE_CXX11_ABI=0 -DCMAKE_INSTALL_PREFIX=$PREFIX -DBOOST_ROOT=$PREFIX -DBoost_NO_SYSTEM_PATHS=ON .
VERBOSE=TRUE make
make install
