#!/bin/bash

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export BOOST_INCLUDE_DIR=${PREFIX}/include
export BOOST_LIBRARY_DIR=${PREFIX}/lib
export BOOST_LIBRARYDIR=${PREFIX}/lib

#export CXXFLAGS=" -std=c++11 -stdlib=libstdc++ -stdlib=libc++ -DUSE_BOOST -I${BOOST_INCLUDE_DIR} -L${BOOST_LIBRARY_DIR}"
export CXXFLAGS=" -std=c++11  -DUSE_BOOST -I${BOOST_INCLUDE_DIR} -L${BOOST_LIBRARY_DIR}"
export LDFLAGS="-L${BOOST_LIBRARY_DIR}"
export Boost_NO_BOOST_CMAKE=TRUE 



mkdir -p $PREFIX/bin

mkdir build
cd build

cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX 
make
make install

