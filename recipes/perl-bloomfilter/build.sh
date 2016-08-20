#!/bin/bash

mkdir -p $PREFIX/bin
cd swig/

mkdir -p perl-lib/lib

PERL5DIR=`(perl -e 'use Config; print $Config{archlibexp}, "\n";') 2>/dev/null`
swig -Wall -c++ -perl5 BloomFilter.i
g++ -c BloomFilter_wrap.cxx -I$PERL5DIR/CORE -fPIC -Dbool=char -O3
g++ -Wall -shared BloomFilter_wrap.o -o BloomFilter.so -O3

cp *.pm perl-lib/lib
cp *.so perl-lib/lib

cp $RECIPE_DIR/Build.PL perl-lib
cd perl-lib
perl ./Build.PL
./Build manifest
./Build install --installdirs site
