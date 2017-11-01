#!/bin/bash


if [[ `uname` == Darwin ]]; then
    export CC=gcc
    export CXX=g++
fi 

./autogen.sh
./configure --prefix=${PREFIX}
make
mv src/parsnp ${PREFIX}/bin/

