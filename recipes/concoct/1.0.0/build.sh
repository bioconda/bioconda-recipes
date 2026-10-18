#!/bin/bash

# Ensure C compiler is visible to setuptools/pip
export CC=${CC:-$(which ${GCC:-gcc})}
export LDSHARED="$CC -shared"

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

$PYTHON setup.py install --single-version-externally-managed --record=record.txt