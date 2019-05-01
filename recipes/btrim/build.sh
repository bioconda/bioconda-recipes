#!/bin/bash

make CC=$CXX LDFLAGS="-L$PREFIX/lib -pthread -fopenmp"

mkdir -p $PREFIX/bin
cp btrim $PREFIX/bin
