#!/bin/bash

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/lib
mkdir -p ${PREFIX}/test

# compiles and moves libssw to conda env
cd ssw201507

${CC} -Wall -O3 -pipe -fPIC -shared -rdynamic -o libssw.so ssw.c -I. -I"${PREFIX}/include/sse2neon"
mv libssw.so ${PREFIX}/lib/

# moves python scripts to conda env
cd ..

chmod +x isescan.py
install -v -m 0755 *.py "${PREFIX}/bin"
cp -rf pHMMs $PREFIX/bin/

# adds test fasta for build testing
cp NC_012624.fna $PREFIX/test/
