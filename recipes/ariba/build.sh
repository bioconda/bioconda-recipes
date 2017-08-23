#!/bin/bash
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

if [ `uname` == Darwin ]; then
    export MACOSX_DEPLOYMENT_TARGET=10.9
fi

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
