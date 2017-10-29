#!/bin/bash

mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_PREFIX_PATH=$PREFIX ..
make

# Reference link:
# https://github.com/conda/conda-recipes/blob/master/boost/build.sh
