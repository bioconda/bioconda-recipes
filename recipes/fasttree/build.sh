#!/bin/bash
mkdir -p $PREFIX/bin

gcc -O3 -DUSE_DOUBLE -finline-functions -funroll-loops -Wall -o FastTree FastTree.c -lm
cp FastTree $PREFIX/bin

if [ `uname` != Darwin ]; then
gcc -DOPENMP -fopenmp -O3 -DUSE_DOUBLE -finline-functions -funroll-loops -Wall -o FastTreeMP FastTree.c -lm
cp FastTreeMP $PREFIX/bin
fi

