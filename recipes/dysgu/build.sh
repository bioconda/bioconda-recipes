#!/bin/bash
export CXXFLAGS+="-Wunreachable-code-fallthrough -Wdeprecated-builtins -I$PREFIX/include"
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export C_INCLUDE_PATH=${PREFIX}/include

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
