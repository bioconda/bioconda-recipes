#!/bin/bash

gcc -O3 -DUSE_DOUBLE -finline-functions -funroll-loops -Wall -o FastTree FastTree.c -lm
gcc -DOPENMP -fopenmp -O3 -finline-functions -funroll-loops -Wall -o FastTreeMP FastTree.c -lm

mkdir -p $PREFIX/bin
cp FastTree $PREFIX/bin
cp FastTreeMP $PREFIX/bin

#gcc -DNO_SSE -O3 -finline-functions -funroll-loops -Wall -o FastTree FastTree.c -lm
#gcc -DNO_SSE -O3 -funroll-loops -Wall -o FastTree FastTree.c -lm
