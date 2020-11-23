#!/bin/bash

make CC="$CC" CXX="$CXX" AR="$AR" RANLIB="$RANLIB" CPPFLAGS="$CPPFLAGS" CXXFLAGS="$CXXFLAGS -std=c++14" LDFLAGS="$LDFLAGS"
make install_prefix="$PREFIX" install
