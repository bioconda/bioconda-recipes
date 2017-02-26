#!/bin/bash

gcc -O3 -DUSE_DOUBLE -finline-functions -funroll-loops -Wall -o FastTree FastTree.c -lm
gcc -DOPENMP -fopenmp -O3 -DUSE_DOUBLE -finline-functions -funroll-loops -Wall -o FastTreeMP FastTree.c -lm

mkdir -p $PREFIX/bin
chmod +x FastTree
chmod +x FastTreeMP

mv -v ./FastTree* $PREFIX/bin
