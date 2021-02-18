#!/bin/bash

./bootstrap
./configure --prefix=$PREFIX CXXFLAGS="-O2"
make
make install
