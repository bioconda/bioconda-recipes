#!/bin/bash

# update environment variables
export CFLAGS="$CFLAGS -I$PREFIX/include"
export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPATH=${PREFIX}/include
export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LIBRARY_PATH=${PREFIX}/lib

# compile ViralConsensus
make CC=$CC CXX="${CXX}"
if [ ! -d "$PREFIX/bin" ]; then
    mkdir $PREFIX/bin;
    export PATH=$PREFIX/bin:$PATH;
fi
cp viral_consensus $PREFIX/bin/
