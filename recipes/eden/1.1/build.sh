#!/bin/sh
export CXXFLAGS="$CXXFLAGS -I$PREFIX/include"
#sed -i "s|-c EDeN.cc|$CFLAGS -c EDeN.cc|" Makefile
sed -i.bak "s/CXX=g++//g" Makefile
cat Makefile
make
mkdir -p ${PREFIX}/bin
cp EDeN ${PREFIX}/bin
