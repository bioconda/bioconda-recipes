#!/bin/bash

#strictly use anaconda build environment
export CC=${PREFIX}/bin/gcc
export CXX=${PREFIX}/bin/g++
export CPPFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib"

./configure --prefix=$PREFIX
make
make install