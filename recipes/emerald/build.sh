#!/bin/sh

export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPATH=${PREFIX}/include

export CFLAGS="${CFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
[ "$unamestr" == 'Darwin' ] && export MACOSX_DEPLOYMENT_TARGET=10.15

cmake .
make

mkdir -p $PREFIX/bin
cp $SRC_DIR/emerald $PREFIX/bin
