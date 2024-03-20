#!/usr/bin/env bash

export CPPFLAGS="-I$PREFIX/include -I$PREFIX/include/lzo $CPPFLAGS"
export LDFLAGS="-L$PREFIX/lib $LDFLAGS"

python -m pip install --no-deps --ignore-installed .
