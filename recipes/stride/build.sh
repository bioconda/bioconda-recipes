#!/bin/bash

./autogen.sh
./configure --prefix=$PREFIX --with-sparsehash=$PREFIX
make CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" AM_CXXFLAGS=''
make install
