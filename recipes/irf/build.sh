#!/bin/bash
mkdir -p "${PREFIX}"/bin
cd src
$CC -c -o irf.o irf.3.c -O2
$CC -c -o easylife.o easylife.c -O2
$CC -o $PREFIX/bin/irf irf.o easylife.o -lm
rm -f *.o
