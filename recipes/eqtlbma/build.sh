#!/bin/bash

export CPATH=${PREFIX}/include
export LD_LIBRARY_PATH=${PREFIX}/lib
if [ `uname` == Darwin ]; then
        export CPPFLAGS="-fpermissive"
fi

autoreconf --install --force --symlink
./configure --prefix=${PREFIX}
make
make install
