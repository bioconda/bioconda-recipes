#!/bin/bash

mkdir -p $PREFIX/bin

cd src
# malloc.h is a Linux-ism
sed -i.bak "s/malloc.h/stdlib.h/" load_unipath_size.c
make INCLUDES="-I$PREFIX/include" CFLAGS="-g -Wall -O2 -Wc++-compat -L$PREFIX/lib"

cp deSALT deBGA Annotation_Load.py $PREFIX/bin
