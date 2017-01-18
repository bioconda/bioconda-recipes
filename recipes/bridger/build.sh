#!/bin/bash

set -x -e

export INCLUDE_PATH="${PREFIX}/include/"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export BOOST_INCLUDE_DIR="${PREFIX}/include"
export BOOST_LIBRARY_DIR="${PREFIX}/lib"
export LIBS='-lboost_regex -lboost_system -lboost_program_options -lboost_filesystem -lboost_timer'


export CXXFLAGS="-DUSE_BOOST -I${BOOST_INCLUDE_DIR} -L${BOOST_LIBRARY_DIR}"
export LDFLAGS="-L${BOOST_LIBRARY_DIR} -lboost_regex -lboost_filesystem -lboost_system"



mkdir -p $PREFIX/bin
 
./configure --prefix=$PREFIX --with-boost=${PREFIX} --with-boost-libdir=${PREFIX}/lib

make 
make install
