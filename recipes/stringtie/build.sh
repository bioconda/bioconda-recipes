#!/bin/sh

export C_INCLUDE_PATH=$PREFIX/include
export CPLUS_INCLUDE_PATH=$PREFIX/include
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

wget http://ccb.jhu.edu/software/stringtie/dl/prepDE.py

make release
mkdir -p $PREFIX/bin
mv stringtie $PREFIX/bin
mv prepDE.py $PREFIX/bin
