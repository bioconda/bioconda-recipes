#!/bin/sh

./configure --prefix=${PREFIX} --with-simd-level=sse42
make -j 2
make install prefix=${PREFIX}
