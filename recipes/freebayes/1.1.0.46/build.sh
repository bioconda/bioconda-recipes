#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
    # MacOSX Build fix: https://github.com/chapmanb/homebrew-cbl/issues/14.
    sed -i.bak 's/LDFLAGS=-Wl,-s/LDFLAGS=/g' vcflib/smithwaterman/Makefile
    export CXXFLAGS="${CXXFLAGS} -std=c++11 -stdlib=libc++"

    # Patch vcflib: fix for missing <thread> include.
    sed -i.bak 's/-std=c++0x/-std=c++11 -stdlib=libc++/g' vcflib/intervaltree/Makefile
    sed -i.bak 's/-std=c++0x/-std=c++11 -stdlib=libc++/g' vcflib/Makefile
fi

# Patch vcflib.
# Tabix missing library https://github.com/ekg/tabixpp/issues/5.
# Uses newline trick for OSX from: http://stackoverflow.com/a/24299845/252589.
sed -i.bak 's/SUBDIRS=./SUBDIRS=.\'$'\n''LOBJS=tabix.o/' vcflib/tabixpp/Makefile
sed -i.bak 's/-ltabix//' vcflib/Makefile

# Set exports.
export CFLAGS="-I$PREFIX/include"
export C_INCLUDE_PATH=$PREFIX/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

# Make autoversion.
cd src
make autoversion
make CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
cd ..

# Make vcflib (needed for freebayes-parallel).
cd vcflib

export LDFLAGS="-L$PREFIX/lib -L\$(LIB_DIR) -lvcflib -lhts -lpthread -lz -lm -llzma -lbz2"
export INCLUDES="-Ihtslib -I$PREFIX/include -Itabixpp/htslib -I\$(INC_DIR) -L. -Ltabixpp/htslib"
export LIBPATH="-L. -Lhtslib -L$PREFIX/lib"
export CXXFLAGS="-O3 -D_FILE_OFFSET_BITS=64 -std=c++0x"
sed -i.bak 's/make/make -e/' Makefile

make -e

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
