#!/bin/bash
export CFLAGS="${CFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L{$PREFIX}/lib"
export C_INCLUDE_PATH=${PREFIX}/include

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
