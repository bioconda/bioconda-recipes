#!/bin/bash
find $BUILD_PREFIX -name algorithm.hpp
./configure --prefix=$PREFIX
make
make install
