#!/bin/bash
#export CFLAGS="-I$PREFIX/include"
#export CPPFLAGS="-I$PREFIX/include"
#export LDFLAGS="-L$PREFIX/lib"

#(cd c/libcfu-0.03/ && automake --add-missing && make)
(cd c/ && ./autogen.sh)

$PYTHON setup.py install
