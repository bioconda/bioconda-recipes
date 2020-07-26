#!/bin/bash

cd gatb-core

rm -rf thirdparty/hdf5 thirdparty/boost

# gatb wants an hdf5 dir
ln -s ${PREFIX}/include ${PREFIX}/include/hdf5

mkdir build
cd build

export CXXFLAGS="${CXXFLAGS} -D__STDC_FORMAT_MACROS"

cmake -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX -DZLIB_INCLUDE_DIR:PATH=$PREFIX"/include" ..
make VERBOSE=1
make install
