#!/bin/bash
export CPPLAGS="$CPPFLAGS -I$PREFIX/include -I$BUILD_PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib -L$BUILD_PREFIX/lib"

mkdir build && cd build
../configure --prefix ${PREFIX}
make
make install
