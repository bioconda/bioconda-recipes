#!/bin/bash

#strictly use anaconda build environment
CC=${PREFIX}/bin/gcc
CXX=${PREFIX}/bin/g++

mkdir -p $PREFIX/bin

./install.sh

mv exe/* $PREFIX/bin


