#!/bin/bash
set -eu -o pipefail
unset CFLAGS
unset CXXFLAGS
make SFLAGS=
make install
mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin
