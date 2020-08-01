#!/bin/bash
set +ex

export CXXFLAGS="$CXXFLAGS -I$PREFIX/include -L$PREFIX/lib"

# build
./autogen.sh
./configure --prefix=${PREFIX} --with-boost=${PREFIX} 
make
make install
