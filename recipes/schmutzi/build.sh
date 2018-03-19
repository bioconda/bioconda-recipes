#!/bin/bash

#Building according to instructions at Schmutzi repository

CC=${PREFIX}/bin/gcc
CXX=${PREFIX}/bin/g++

./configure --prefix=${PREFIX}
make
