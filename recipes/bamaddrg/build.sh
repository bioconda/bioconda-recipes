#!/bin/bash

export INCLUDE_PATH="${PREFIX}/include/:${PREFIX}/include/bamtools/"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"


sed -i.bak "s#g++#$CXX#g" Makefile
make CXX=${CXX} 
