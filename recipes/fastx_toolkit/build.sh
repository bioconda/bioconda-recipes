#!/bin/bash

export GTEXTUTILS_CFLAGS="-I $PREFIX/include/gtextutils"
export GTEXTUTILS_LIBS="$PREFIX/lib/libgtextutils.a"

if [ "$(uname)" == "Darwin" ]; then
    MACOSX_DEPLOYMENT_TARGET=10.7
    CXXFLAGS="${CXXFLAGS} -std=c++11 -stdlib=libc++"
fi

./configure --prefix=$PREFIX
make
make install
