#!/bin/bash

#This won't build on OSX without this
export DYLD_LIBRARY_PATH=$PREFIX/lib:$PREFIX
export C_INCLUDE_PATH=$PREFIX/include

export CPPFLAGS="-std=c++11"
./configure --prefix=$PREFIX
make
make install
