#!/bin/bash
set -eu -o pipefail
unset CFLAGS
unset CXXFLAGS
make all SFLAGS=
make install_all
mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin
