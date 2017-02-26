#!/bin/bash
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include -I${PREFIX}/include/bam"

mkdir -p $PREFIX/bin
./configure --prefix=$PREFIX --with-bam_inc=$PREFIX/include/bam --with-bam_lib=$PREFIX/lib
make clean # Some leftovers needs to be removed
make 
make install
