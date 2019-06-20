#!/bin/bash
if [ "$(uname)" == "Darwin" ]; then
    echo "Use *.dylib for OSX"
    export JELLYFISH2_0_LIBS=$PREFIX/lib/libjellyfish-2.0.dylib
    export JELLYFISH2_0_CFLAGS=${PREFIX}/include/jellyfish-2.2.10
else
    echo "Use *.so for Linux"
    export JELLYFISH2_0_LIBS=$PREFIX/lib/libjellyfish-2.0.so
fi

export LIBRARY_PATH=${PREFIX}/lib
export CPP_INCLUDE_PATH=${PREFIX}/include:${PREFIX}/include/jellyfish-2.2.10
export CPLUS_INCLUDE_PATH=${PREFIX}/include:${PREFIX}/include/jellyfish-2.2.10
export CXX_INCLUDE_PATH=${PREFIX}/include:${PREFIX}/include/jellyfish-2.2.10
./configure --prefix=$PREFIX
make
make install
