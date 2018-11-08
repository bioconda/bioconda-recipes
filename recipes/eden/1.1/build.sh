#!/bin/sh
export CXXFLAGS="$CXXFLAGS -I$PREFIX/include"
export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
sed -i.bak "s|-c EDeN.cc|$CPPFLAGS -c EDeN.cc|" Makefile
sed -i.bak "s/CXX=g++//g" Makefile
cat Makefile
make
mkdir -p ${PREFIX}/bin
cp EDeN ${PREFIX}/bin
