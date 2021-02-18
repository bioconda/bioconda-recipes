#!/bin/bash

./bootstrap
./configure --prefix=$PREFIX CXXFLAGS="-O2 -I$CONDA_PREFIX/include"
make
make install
