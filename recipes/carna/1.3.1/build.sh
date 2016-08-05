#!/bin/sh
./configure --prefix=$PREFIX GECODE_HOME=$prefix --disable-gist
make -j${CPU_COUNT}
make install
