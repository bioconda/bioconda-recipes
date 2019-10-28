#!/bin/bash

# compiles and moves libssw to conda env
cd ssw201507
${CC} -Wall -O3 -pipe -fPIC -shared -rdynamic -o libssw.so ssw.c ssw.h
mv libssw.so ${PREFIX}/lib/

# moves python scripts to conda env
cd ..
chmod +x isescan.py
mkdir -p ${PREFIX}/bin/
cp *.py ${PREFIX}/bin/
cp -r pHMMs/ $PREFIX/bin/

# adds test fasta for build testing
mkdir $PREFIX/test
cp NC_012624.fna $PREFIX/test/
