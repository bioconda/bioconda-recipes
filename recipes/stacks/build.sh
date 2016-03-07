#!/bin/bash

#This won't build on OSX without this
export DYLD_LIBRARY_PATH=$PREFIX/lib:$PREFIX

export CPPFLAGS="-std=c++11"
./configure --prefix=$PREFIX
make
make install
