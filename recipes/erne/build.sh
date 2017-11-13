#!/bin/bash

if [ `uname` == Darwin ]; then
	export MACOSX_DEPLOYMENT_TARGET=10.9
	export LDFLAGS="-L${PREFIX}/lib"
	export CXXFLAGS="-stdlib=libc++ -std=c++11"
fi

export C_INCLUDE_PATH=${PREFIX}/include
export LD_LIBRARY_PATH=${PREFIX}/lib
export BOOST_ROOT=${PREFIX}

./configure --prefix=${PREFIX} 
make -j 2
make install
