#!/bin/bash
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export C_INCLUDE_PATH=${PREFIX}/include
touch dysgu/post_call_metrics.pyx
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
