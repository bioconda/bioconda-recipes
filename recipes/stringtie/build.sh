#!/bin/sh

export C_INCLUDE_PATH=$PREFIX/include
export CPLUS_INCLUDE_PATH=$PREFIX/include
export CXXFLAGS="$CXXFLAGS -I$PREFIX/include"
export LINKER="$CXX"
export CXXFLAGS="$CPPFLAGS"

make release
mkdir -p $PREFIX/bin
mv stringtie $PREFIX/bin
