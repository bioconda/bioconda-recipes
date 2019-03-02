#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
    # MacOSX Build fix: https://github.com/chapmanb/homebrew-cbl/issues/14.
    sed -i.bak 's/LDFLAGS=-Wl,-s/LDFLAGS=/g' vcflib/smithwaterman/Makefile
    export CXXFLAGS="${CXXFLAGS} -std=c++11 -stdlib=libc++"

fi

# Fix this ridiculous build by going backwards and starting with vcflib manually

export C_INCLUDE_PATH=$PREFIX/include
export CPLUS_INCLUDE_PATH=$PREFIX/include

export LDFLAGS="-L$PREFIX/lib -L\$(LIB_DIR) -lvcflib -lhts -lpthread -lz -lm -llzma -lbz2"
export INCLUDES="-I . -Ihtslib -I$PREFIX/include -Itabixpp/htslib -I\$(INC_DIR) -L. -Ltabixpp/htslib"
export LIBPATH="-L. -Lhtslib -L$PREFIX/lib"
export CXXFLAGS="-O3 -D_FILE_OFFSET_BITS=64 -std=c++0x"

cd vcflib

sed -i.bak 's/ld/$(LD)/' smithwaterman/Makefile
#sed -i.bak 's/gcc/$(CC) $(CFLAGS)/g' filevercmp/Makefile

cd smithwaterman
make -e

cd ../tabixpp

make -e

cd ..

cp tabixpp/tabix.hpp ../src
#cd ../SeqLib/htslib/
#make
#cd ../

#export CC=${CC}
#export CXX=${CXX}
#export CXXFLAGS=${CXXFLAGS}
#export LDFLAGS="-L$PREFIX/lib"

#./configure --prefix=$PREFIX 

cd ../src

sed -i.bak 's/^CXX=.*$//g' Makefile
sed -i.bak 's/^C=gcc//g' Makefile
sed -i.bak 's/C)/CC)/' Makefile
sed -i.bak "s:INCLUDE =:INCLUDE = -I$PREFIX/include:" Makefile
#sed -i.bak "s:LIBS =:LIBS = -L$PREFIX/lib:" Makefile	

# Set exports.
export CFLAGS="-I$PREFIX/include"
export C_INCLUDE_PATH=$PREFIX/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

sed -i.bak 's/LIBS)/LIBS) ($LIBRARY_PATH)/5' Makefile

# Make autoversion.
make autoversion
make CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
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
cp -r bin/* $PREFIX/bin/

sed -i.bak 's/..\/vcflib\/scripts\///g; s/..\/vcflib\/bin\///g' scripts/freebayes-parallel
cp scripts/freebayes-parallel $PREFIX/bin

sed -i.bak 's@#!/usr/bin/python@#!/usr/bin/env python@g' scripts/fasta_generate_regions.py
cp scripts/fasta_generate_regions.py $PREFIX/bin

cp scripts/coverage_to_regions.py $PREFIX/bin
cp scripts/generate_freebayes_region_scripts.sh $PREFIX/bin

cp vcflib/bin/vcfstreamsort $PREFIX/bin
cp vcflib/bin/vcfuniq $PREFIX/bin
cp vcflib/scripts/vcffirstheader $PREFIX/bin
