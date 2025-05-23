#!/bin/bash

sed -i.bak 's/-march=native/-march=x86-64/' CMakeLists.txt

mkdir build
cd build

export CXXFLAGS="${CXXFLAGS} -std=c++14"

cmake .. \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DBOOST_NO_SYSTEM_PATHS=on \
      -DCMAKE_OSX_DEPLOYMENT_TARGET=""

cmake --build . --config Release --target install -j ${CPU_COUNT}

# Reference link:
# https://github.com/conda/conda-recipes/blob/master/boost/build.sh
