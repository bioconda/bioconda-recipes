#!/bin/bash

mkdir -p $PREFIX/lib $PREFIX/bin $PREFIX/include

make -j"${CPU_COUNT}"

if [ -f libgffc.so ] ; then
    install *.so $PREFIX/lib/
fi

if [ -f libgffc.dylib ] ; then
    install *.dylib $PREFIX/lib/
fi

install *.o $PREFIX/lib/
install *.h $PREFIX/include/
install *.hh $PREFIX/include/
install gtest $PREFIX/bin/
install threads $PREFIX/bin/
