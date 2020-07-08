#!/bin/bash

#export CFLAGS="$CFLAGS -I$PREFIX/include"
#export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
#export CPATH=${PREFIX}/include
#alternative to fix problems with zlib
# export C_INCLUDE_PATH=$C_INCLUDE_PATH:${PREFIX}/include
# export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:${PREFIX}/include
# export LIBRARY_PATH=$LIBRARY_PATH:${PREFIX}/lib

chmod 755 ./configure
./configure --prefix=$PREFIX
make
mv LDBlockShow $PREFIX/bin/LDBlockShow
ln -s $PREFIX/bin/LDBlockShow $PREFIX/bin/ldblockshow
