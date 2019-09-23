#!/bin/bash

mkdir -p $PREFIX/bin

cd src
#malloc.h is a Linux-ism
sed -i.bak "s/malloc.h/stdlib.h/" load_unipath_size.c
sed -i.bak "s/malloc.h/stdlib.h/" graph.c
sed -i.bak "s/malloc.h/stdlib.h/" deBGA-master/load_input.c
sed -i.bak "s/malloc.h/stdlib.h/" deBGA-master/index_build.c

make INCLUDES="-I$PREFIX/include" CFLAGS="-g -Wall -O2 -Wc++-compat -L$PREFIX/lib" LIBS="-lm -lz -lpthread -lomp"

cp deSALT deBGA Annotation_Load.py $PREFIX/bin
