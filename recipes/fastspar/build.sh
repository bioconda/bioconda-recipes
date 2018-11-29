#!/bin/bash

sh autogen.sh

# needed on macos:
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CXXFLAGS="$CXXFLAGS -I$PREFIX/include"

./configure --prefix=$PREFIX || (cat config.log; false)

make -j $CPU_COUNT
make install
