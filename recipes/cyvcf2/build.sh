#!/bin/bash
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export C_INCLUDE_PATH=${PREFIX}/include
CYTHONIZE=1 $PYTHON setup.py install --single-version-externally-managed --record=record.txt
