#!/bin/bash
find $PREFIX -name algorithm.hpp
./configure --prefix=$PREFIX
make
make install
