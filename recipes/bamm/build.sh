#!/bin/bash
export CFLAGS="-I$PREFIX/include"
export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

$PYTHON setup.py install
#--with-libhts-lib $PREFIX/lib \
# --with-libhts-inc $PREFIX/include --with-libcfu-inc $PREFIX/include \
# --with-libcfu-lib $PREFIX/lib
