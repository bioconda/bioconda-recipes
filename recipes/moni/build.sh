#!/bin/bash

set -xe

export CPATH=$PREFIX/include:$CPATH
export LIBRARY_PATH=$PREFIX/lib:$LIBRARY_PATH
export LD_LIBRARY_PATH=$PREFIX/lib:$LD_LIBRARY_PATH

mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_INCLUDE_PATH=$PREFIX/include \
      -DCMAKE_LIBRARY_PATH=$PREFIX/lib \
      -DZLIB_ROOT=$PREFIX \
      ..
make -j ${CPU_COUNT} VERBOSE=1
make install
