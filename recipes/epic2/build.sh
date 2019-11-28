#!/bin/bash

export CPPFLAGS="-DHAVE_LIBDEFLATE -I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

$PYTHON setup.py install --single-version-externally-managed --record=record.txt && $PYTHON setup.py build_ext --inplace

