#!/bin/bash

# MacOSX Build fix: https://github.com/chapmanb/homebrew-cbl/issues/14
if [ "$(uname)" == "Darwin" ]; then
   sed -i.bak 's/LDFLAGS=-Wl,-s/LDFLAGS=/' vcflib/smithwaterman/Makefile
   export CXXFLAGS="${CXXFLAGS} -std=c++11 -stdlib=libc++"
fi

export C_INCLUDE_PATH=$PREFIX/include
export CFLAGS="-I$PREFIX/include"

# bamtools/cmake for zlib
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

pythonfiles="scripts/fasta_generate_regions.py scripts/coverage_to_regions.py"

PY3_BUILD="${PY_VER%.*}"

if [ $PY3_BUILD -eq 3 ]
then
    for i in $pythonfiles; do 2to3 --write $i; done
fi

mkdir -p $PREFIX/bin
cp -r bin/* $PREFIX/bin
cp scripts/freebayes-parallel $PREFIX/bin
sed -i.bak 's@#!/usr/bin/python@#!/usr/bin/env python@g' scripts/fasta_generate_regions.py
cp scripts/fasta_generate_regions.py $PREFIX/bin
cp scripts/coverage_to_regions.py $PREFIX/bin
cp scripts/generate_freebayes_region_scripts.sh $PREFIX/bin
