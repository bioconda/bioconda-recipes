#!/bin/bash
set -xe

if [ "$(uname -s)" == Darwin ] ; then
 	CXXFLAGS="$CXXFLAGS -D_LIBCPP_DISABLE_AVAILABILITY"
fi

export CXXFLAGS="$CXXFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

make -j ${CPU_COUNT} COMPILER=$CXX
chmod 0755 krepp

mkdir -p $PREFIX/bin
cp krepp $PREFIX/bin
