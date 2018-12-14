#!/bin/bash
export CFLAGS="-I$PREFIX/include"
export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

(rm -rf c/htslib-1.3.1/)
(cd c/ && ./autogen.sh)

$PYTHON setup.py install --with-libhts-lib ${PREFIX}/lib --with-libhts-inc ${PREFIX}/include/htslib