#!/bin/sh
export CXXFLAGS="$CXXFLAGS -I$PREFIX/include"
sed -i "s|-c EDeN.cc|$CFLAGS -c EDeN.cc|" Makefile
make
mkdir -p ${PREFIX}/bin
cp EDeN ${PREFIX}/bin
