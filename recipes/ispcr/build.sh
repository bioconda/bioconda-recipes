#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/share/doc/ispcr

# based on https://raw.githubusercontent.com/brewsci/homebrew-bio/de917e71b442af197523131406bfcd577221089c/Formula/ispcr.rb
export MACHTYPE=unix
mkdir -p "bin/$MACHTYPE"
mkdir -p "lib/$MACHTYPE"

make HOME=$PWD CC=${CC} CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}"

for f in bin/$MACHTYPE/* ; do mv $f $PREFIX/bin/; done
cp README $PREFIX/share/doc/ispcr/
