#!/bin/sh
set -x -e

# echo "CFLAGS=$CFLAGS"
# echo "CPPFLAGS=$CPPFLAGS"
# echo "CXXFLAGS=$CXXFLAGS"
# echo "LDFLAGS=$LDFLAGS"

export CFLAGS="-I$PREFIX/include $CFLAGS"
export CPPFLAGS="-I$PREFIX/include $CPPFLAGS"
export CXXFLAGS="-I$PREFIX/include $CXXFLAGS"
export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
export LIBS="-lm ${PREFIX}/lib/libz.a"

./autogen.sh
#./configure --disable-silent-rules --disable-dependency-tracking --prefix=$PREFIX
./configure --disable-silent-rules --disable-dependency-tracking --prefix=${PREFIX} --with-boost=${PREFIX} --with-boost-libdir=${PREFIX}/lib
make V=1
make V=1 check
make install
