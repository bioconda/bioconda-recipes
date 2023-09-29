#!/bin/bash

# pull htslib submodule (and its submodules) manually since ViralConsensus tarball isn't git repo
sed -i.bak 's/git submodule/#git submodule/g' Makefile
git clone --recurse-submodules https://github.com/samtools/htslib.git

# htslib compilation calls gcc, so link bioconda's gcc/g++
ln -s $CC ${PREFIX}/bin/gcc
ln -s $CXX ${PREFIX}/bin/g++

# htslib compilation needs zlib and other libraries, so specify bioconda's libraries
export CFLAGS="$CFLAGS -I$PREFIX/include -fpermissive"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPATH=${PREFIX}/include
export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"

# need fpermissive because ViralConsensus is C++ but htslib is C and uses implicit pointer conversion
export CPPFLAGS="-fpermissive"

# compile ViralConsensus
make CXX="${CXX}" CXXFLAGS+='-fpermissive'
if [ ! -d "$PREFIX/bin" ]; then
    mkdir $PREFIX/bin;
    export PATH=$PREFIX/bin:$PATH;
fi
cp viral_consensus $PREFIX/bin/
