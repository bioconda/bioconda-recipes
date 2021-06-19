#!/bin/bash
make cxx=$CXX cxxflags="-O3 -Wall -I$PREFIX/include -std=c++11 -fopenmp" ldflags="-L$PREFIX/lib -lm -lz"
mkdir -p $PREFIX/bin
mv chromap $PREFIX/bin
