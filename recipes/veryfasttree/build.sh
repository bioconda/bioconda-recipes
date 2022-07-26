#!/bin/bash
cmake -DUSE_NATIVE=OFF -USE_AVX2=ON .
make
mkdir -p $PREFIX/bin
cp VeryFastTree $PREFIX/bin/VeryFastTree 
