#! /bin/bash
mkdir -p $PREFIX/bin
cd renano

make INCLUDES="-I$PREFIX/include" CFLAGS="-fopenmp -std=c++11 -O3 -march=native -fstrict-aliasing -ffast-math -fomit-frame-pointer -Wall -L$PREFIX/lib"
cp renano $PREFIX/bin
