#!/bin/bash

export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

sed -i.bak 's/g++/$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(LDFLAGS)/g' Makefile

make

mkdir -p ${PREFIX}/bin

install -m775 GWAMA ${PREFIX}/bin/
