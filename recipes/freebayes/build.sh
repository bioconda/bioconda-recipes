#!/bin/bash

# MacOSX Build fix: https://github.com/chapmanb/homebrew-cbl/issues/14
if [ "$(uname)" == "Darwin" ]; then
   sed -i 's/LDFLAGS=-Wl,-s/LDFLAGS=/g' vcflib/smithwaterman/Makefile
fi
# tabix missing library https://github.com/ekg/tabixpp/issues/5
sed -i 's/SUBDIRS=./SUBDIRS=.\'$'\n''LOBJS=tabix.o/g' vcflib/tabixpp/Makefile
sed -i 's/-ltabix//g' vcflib/Makefile

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
