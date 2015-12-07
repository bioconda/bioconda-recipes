#!/bin/bash

mkdir build
cd build

cmake .. \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DBOOST_NO_SYSTEM_PATHS=on

cmake --build . --config Release --target install

# Reference link:
# https://github.com/conda/conda-recipes/blob/master/boost/build.sh
