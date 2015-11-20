#!/bin/bash

# MacOSX Build fix: https://github.com/chapmanb/homebrew-cbl/issues/14
if [ "$(uname)" == "Darwin" ]; then
   sed -i.bak 's/LDFLAGS=-Wl,-s/LDFLAGS=/' vcflib/smithwaterman/Makefile
fi
# tabix missing library https://github.com/ekg/tabixpp/issues/5
# Uses newline trick for OSX from: http://stackoverflow.com/a/24299845/252589
sed -i.bak 's/SUBDIRS=./SUBDIRS=.\'$'\n''LOBJS=tabix.o/' vcflib/tabixpp/Makefile
sed -i.bak 's/-ltabix//' vcflib/Makefile

mkdir -p bamtools/build
cd bamtools/build
cmake ..
cd ../..

cd src
make autoversion
make
cd ..

mkdir -p $PREFIX/bin
cp bin/freebayes $PREFIX/bin
cp scripts/freebayes-parallel $PREFIX/bin
sed -i 's@#!/usr/bin/python@#!/usr/bin/env python@g' scripts/fasta_generate_regions.py
cp scripts/fasta_generate_regions.py $PREFIX/bin
cp scripts/coverage_to_regions.py $PREFIX/bin
cp scripts/generate_freebayes_region_scripts.sh $PREFIX/bin
