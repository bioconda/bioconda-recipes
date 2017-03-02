#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LD_LIBRARY_PATH=${PREFIX}/lib
export BOOST_ROOT=${PREFIX}

./configure --prefix=${PREFIX} 
make -j 2
make install
