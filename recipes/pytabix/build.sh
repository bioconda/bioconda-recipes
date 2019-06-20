#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export LD_LIBRARY_PATH="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
