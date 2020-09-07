#!/bin/bash

#to fix problems with htslib
export C_INCLUDE_PATH=$C_INCLUDE_PATH:${PREFIX}/include
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:${PREFIX}/include
export LIBRARY_PATH=$LIBRARY_PATH:${PREFIX}/lib
export LD_LIBRARY_PATH=$LIBRARY_PATH:${PREFIX}/lib

./configure --prefix=$PREFIX --enable-hts
make
make install
