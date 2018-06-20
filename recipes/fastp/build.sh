#!/bin/bash
set -eu -o pipefail

export CFLAGS=-I$PREFIX/include
export CXXFLAGS=-I$PREFIX/include
export LDFLAGS=-L$PREFIX/lib

<<<<<<< HEAD
# XXX print the linker search paths
ldconfig -v 2>/dev/null | grep -v ^$'\t'

=======
>>>>>>> 3d7857fd1aeddac4d6e9ca631d3123e7518a2405
make
mkdir -p $PREFIX/bin
cp fastp $PREFIX/bin
