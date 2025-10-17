#!/bin/bash
export CC=$CC
sed -i '41错、CXX ?= g++' Makefile
mkdir -p $PREFIX/lib $PREFIX/bin $PREFIX/include
make CXX="$CXX" CXXFLAGS="$CXXFLAGS -Wno-register" LDFLAGS="$LDFLAGS" PREFIX="$PREFIX"
install *.o $PREFIX/lib/
if [ -f libgffc.so ] ; then
    install *.so $PREFIX/lib/
fi
if [ -f libgffc.dylib ] ; then
    install *.dylib $PREFIX/lib/
fi
install *.h $PREFIX/include/
install *.hh $PREFIX/include/
install gtest $PREFIX/bin/
install threads $PREFIX/bin/
