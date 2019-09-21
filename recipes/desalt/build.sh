#!/bin/bash

mkdir -p $PREFIX/bin

cd src
make INCLUDES="-I$PREFIX/include" CFLAGS="-g -Wall -O2 -Wc++-compat -L$PREFIX/lib"

cp deSALT deBGA Annotation_Load.py $PREFIX/bin
