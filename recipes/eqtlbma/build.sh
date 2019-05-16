#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
if [ `uname` == Darwin ]; then
        export CPPFLAGS="-fpermissive"
fi

autoreconf --install --force --symlink
./configure --prefix=${PREFIX}
make
make install
