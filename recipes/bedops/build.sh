#!/bin/bash
set -eu -o pipefail
make all CC=$CC CXX=$CXX SFLAGS=
make install_all
mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin
