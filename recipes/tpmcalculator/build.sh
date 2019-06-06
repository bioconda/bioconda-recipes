#!/usr/bin/env bash

export CPPFLAGS="-I$PREFIX/include/bamtools"
export LDFLAGS="-L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"

make
cp bin/TPMCalculator $PREFIX/bin/
