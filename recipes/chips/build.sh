#!/bin/bash

# export C_INCLUDE_PATH=$C_INCLUDE_PATH:${PREFIX}/include
# export CPP_INCLUDE_PATH=$CPP_INCLUDE_PATH:${PREFIX}/include
# export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:${PREFIX}/include
# export CXX_INCLUDE_PATH=$CXX_INCLUDE_PATH:${PREFIX}/include

# export LIBRARY_PATH=$LIBRARY_PATH:${PREFIX}/lib
export CFLAGS="$CFLAGS -I$PREFIX/include -std=c++11"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib -lz"
# export CPATH=$CPATH:${PREFIX}/include

mkdir build
cd build
cmake ..
#make CC=$CC CFLAGS="$CFLAGS -DVERSION=1.2.3" LDFLAGS+="-lz $LDFLAGS"
make CC=$CC
