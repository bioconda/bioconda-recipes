#!/bin/bash
set -xe

export CFLAGS="${CFLAGS} -fcommon -g -Wall -O3 -Wc++-compat -L$PREFIX/lib -fopenmp"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p "$PREFIX/bin"

cd src

#malloc.h is a Linux-ism
sed -i.bak "s/malloc.h/stdlib.h/" load_unipath_size.c
sed -i.bak "s/malloc.h/stdlib.h/" graph.c
sed -i.bak "s/malloc.h/stdlib.h/" deBGA-master/load_input.c
sed -i.bak "s/malloc.h/stdlib.h/" deBGA-master/index_build.c
rm -f *.bak

make -j"${CPU_COUNT}" INCLUDES="-I$PREFIX/include" CFLAGS="${CFLAGS}" LIBS="-lm -lz -pthread"

install -v -m 0755 deSALT deBGA Annotation_Load.py "$PREFIX/bin"
