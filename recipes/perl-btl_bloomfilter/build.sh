#!/bin/bash

mkdir -p $PREFIX/bin
cd swig/


PERL5DIR=`(perl -e 'use Config; print $Config{archlibexp}, "\n";') 2>/dev/null`
swig -Wall -c++ -perl5 BloomFilter.i
g++ -c BloomFilter_wrap.cxx -I$PERL5DIR/CORE -fPIC -Dbool=char -O3
g++ -Wall -shared BloomFilter_wrap.o -o BloomFilter.so -O3


h2xs -n BTL::BloomFilter -O  -F -'I ../../../'
cd BTL-BloomFilter
perl Makefile.PL
make
make install
