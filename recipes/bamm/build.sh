#!/bin/bash
export CFLAGS="-I$PREFIX/include"
export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

export HTSLIB_LIBRARY_DIR=$PREFIX/lib
export HTSLIB_INCLUDE_DIR=$PREFIX/include
$PYTHON setup.py install
