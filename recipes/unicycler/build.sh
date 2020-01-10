#!/bin/bash

set -e

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH="${PREFIX}/include"

# Override Makefile -mtune=native
export CXXFLAGS="-mtune=generic"

python -m pip install --no-deps --ignore-installed .
