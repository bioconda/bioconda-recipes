#!/bin/bash
CPPFLAGS+=-I $BUILD_PREFIX/include
LDFLAGS+=-L  $BUILD_PREFIX/lib
export CPPFLAGS
export LDFLAGS

echo "Current path is $PWD"
ls $PWD
mkdir build && cd build
../configure --prefix ${PREFIX}
make
make install
