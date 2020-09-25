#!/bin/sh

set -e -u -x

if [ `uname` == Darwin ]; then
    ./configure CC="clang" --prefix=$PREFIX --enable-threads
else
    ./configure --prefix=$PREFIX --enable-threads
fi

make
make install
