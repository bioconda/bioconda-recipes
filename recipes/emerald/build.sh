#!/bin/sh

export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPATH=${PREFIX}/include
export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

cmake .
make

mkdir -p $PREFIX/bin
cp $SRC_DIR/emerald $PREFIX/bin
