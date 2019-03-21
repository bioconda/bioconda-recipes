#!/bin/bash
export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

(rm -rf c/htslib-1.3.1/)
(cd c/ && touch ChangeLog && ./autogen.sh)

$PYTHON setup.py install --with-libhts-lib ${PREFIX}/lib --with-libhts-inc ${PREFIX}/include/htslib
