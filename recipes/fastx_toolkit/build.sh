#!/bin/bash

export GTEXTUTILS_CFLAGS="-I $PREFIX/include/gtextutils"
export GTEXTUTILS_LIBS="$PREFIX/lib/libgtextutils.a"

./configure --prefix=$PREFIX
make
make install
