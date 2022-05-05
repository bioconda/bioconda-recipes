#!/usr/bin/env bash

mkdir -p "${PREFIX}"/bin

export CXXPATH=${PREFIX}/include

make INCLUDES="-I$PREFIX/include" CXXFLAG="-g -Wall -O2 -std=c++11" 
cp Fec $PREFIX/bin
