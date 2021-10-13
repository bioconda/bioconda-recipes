#!/bin/bash
# -msse4.1 needed for _mm_min_epi32
make cxx=$CXX cxxflags="-O3 -Wall -I$PREFIX/include -std=c++11 -msse4.1 -fopenmp" ldflags="-L$PREFIX/lib -lm -lz"
mkdir -p $PREFIX/bin
mv chromap $PREFIX/bin
