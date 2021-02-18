#!/bin/bash

./bootstrap
./configure --prefix=$PREFIX CXXFLAGS="-O2 -I$PREFIX/include"
make
make install
