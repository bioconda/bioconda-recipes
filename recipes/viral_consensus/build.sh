#!/bin/bash

# use bioconda's htslib instead of the one pulled by ViralConsensus
sed -i.bak 's/htslib\/htslib/htslib/g' common.h
sed -i.bak 's/git submodule/#git submodule/g' Makefile
sed -i.bak 's/ $(HTSLIB_A)//g' Makefile
sed -i.bak 's/^htslib\//#htslib\//g' Makefile
sed -i.bak 's/git submodule/#git submodule/g' Makefile
sed -i.bak 's/cd htslib/#cd htslib/g' Makefile

# htslib compilation calls gcc, so link bioconda's gcc/g++
ln -s $CC ${PREFIX}/bin/gcc
ln -s $CXX ${PREFIX}/bin/g++

# update environment variables
export CFLAGS="$CFLAGS -I$PREFIX/include -fpermissive"
export CPPFLAGS="-fpermissive"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPATH=${PREFIX}/include
export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"

# compile ViralConsensus
make CXX="${CXX}" CXXFLAGS+='-fpermissive'
if [ ! -d "$PREFIX/bin" ]; then
    mkdir $PREFIX/bin;
    export PATH=$PREFIX/bin:$PATH;
fi
cp viral_consensus $PREFIX/bin/

# remove symlinks (they're only needed for compilation)
rm ${PREFIX}/bin/gcc ${PREFIX}/bin/g++
