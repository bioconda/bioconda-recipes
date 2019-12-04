#!/bin/bash
mkdir -p $PREFIX/bin/

make CC=$CXX CFLAGS="$CXXFLAGS" LDFLAGS="$LDFLAGS -pthread -static-libstdc++"

cp bin/* $PREFIX/bin/
