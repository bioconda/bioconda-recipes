#!/bin/bash

if [ "$(uname)" = Darwin ]; then
    export CXXFLAGS="${CXXFLAGS} -stdlib=libc++ -std=c++11"
fi

autoreconf -fi
./configure --prefix="${PREFIX}" --with-boost="${PREFIX}"
make -j 2
make install
