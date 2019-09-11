#!/bin/bash

export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

cd gatb-core

rm -rf thirdparty/hdf5 thirdparty/boost

# gatb wants an hdf5 dir
ln -s ${PREFIX}/include ${PREFIX}/include/hdf5

mkdir build
cd build

cmake -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX -DZLIB_INCLUDE_DIR:PATH=$PREFIX"/include" ..
make VERBOSE=1
make install
