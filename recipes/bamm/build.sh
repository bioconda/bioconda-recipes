#!/bin/bash
#export CFLAGS="-I$PREFIX/include"
#export CPPFLAGS="-I$PREFIX/include"
#export LDFLAGS="-L$PREFIX/lib"

(cd c/libcfu-0.03/ && automake --add-missing && make)

$PYTHON setup.py install
