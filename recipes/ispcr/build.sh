#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

# based on https://raw.githubusercontent.com/brewsci/homebrew-bio/de917e71b442af197523131406bfcd577221089c/Formula/ispcr.rb

export MACHTYPE=unix
mkdir -p "bin/$MACHTYPE"
mkdir -p "lib/$MACHTYPE"

make HOME=$PWD CC=${CC} CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}"

install -t "$PREFIX/bin" "$MACHTYPE/bin/*Pcr"
install -t "$PREFIX/share/doc/ispcr" "README"
