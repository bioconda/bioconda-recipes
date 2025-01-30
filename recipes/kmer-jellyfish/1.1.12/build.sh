#!/bin/bash

autoreconf -fi
export CXXFLAGS="${CXXFLAGS} -fsigned-char"
export CFLAGS="${CFLAGS} -fsigned-char"
./configure --prefix=$PREFIX
make -j ${CPU_COUNT}
make install
