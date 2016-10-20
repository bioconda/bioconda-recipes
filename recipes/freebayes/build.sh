#!/bin/bash

# MacOSX Build fix: https://github.com/chapmanb/homebrew-cbl/issues/14
if [ "$(uname)" == "Darwin" ]; then
   sed -i.bak 's/LDFLAGS=-Wl,-s/LDFLAGS=/' vcflib/smithwaterman/Makefile
fi

# Bamtools/cmake for zlib.
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

mkdir -p bamtools/build
cd bamtools/build
cmake ..
cd ../..

cd src
make autoversion
make CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
cd ..

# Build vcflib (needed for freebayes-parallel).
export C_INCLUDE_PATH=$PREFIX/include

cd vcflib

# Tabix missing library https://github.com/ekg/tabixpp/issues/5
# Uses newline trick for OSX from: http://stackoverflow.com/a/24299845/252589
sed -i.bak 's/SUBDIRS=./SUBDIRS=.\'$'\n''LOBJS=tabix.o/' tabixpp/Makefile
sed -i.bak 's/-ltabix//' Makefile

make

cd ..

# Translate for Python 3 if needed.
pythonfiles="scripts/fasta_generate_regions.py scripts/coverage_to_regions.py vcflib/scripts/vcffirstheader"

PY3_BUILD="${PY_VER%.*}"

if [ $PY3_BUILD -eq 3 ]
then
    for i in $pythonfiles; do 2to3 --write $i; done
fi

# Copy executables.
mkdir -p $PREFIX/bin
cp -r bin/* $PREFIX/bin

sed -i.bak 's/..\/vcflib\/scripts\///g; s/..\/vcflib\/bin\///g' scripts/freebayes-parallel
cp scripts/freebayes-parallel $PREFIX/bin

sed -i.bak 's@#!/usr/bin/python@#!/usr/bin/env python@g' scripts/fasta_generate_regions.py
cp scripts/fasta_generate_regions.py $PREFIX/bin

cp scripts/coverage_to_regions.py $PREFIX/bin
cp scripts/generate_freebayes_region_scripts.sh $PREFIX/bin

cp vcflib/bin/vcfstreamsort $PREFIX/bin
cp vcflib/bin/vcfuniq $PREFIX/bin
cp vcflib/scripts/vcffirstheader $PREFIX/bin
