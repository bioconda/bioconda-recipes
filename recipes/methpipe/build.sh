#!/bin/bash
export CPPLAGS="$CPPFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

mkdir build && cd build
../configure --prefix ${PREFIX}
make
make install
