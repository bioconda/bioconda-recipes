#!/bin/bash
export CFLAGS="-I$PREFIX/include"
export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

if [ "$(uname)" == "Darwin" ]; then
    rvm get head
fi


$PYTHON setup.py install
