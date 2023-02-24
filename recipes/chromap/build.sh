#!/bin/bash
# -msse4.1 needed for _mm_min_epi32
make CXX=$CXX CXXFLAGS="-O3 -Wall -I$PREFIX/include -std=c++11 -msse4.1 -fopenmp" LDFLAGS="-L$PREFIX/lib -lm -lz"
mkdir -p $PREFIX/bin
mv chromap $PREFIX/bin
