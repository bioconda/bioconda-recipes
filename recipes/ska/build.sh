#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
   make CXX="$CXX" CXXFLAGS="$CXXFLAGS" LDFLAGS="-L$PREFIX/lib -lz"
fi

if [ "$(uname)" == "Linux" ]; then
   make CXX="$CXX" CXXFLAGS="$CXXFLAGS" LDFLAGS="-static -static-libstdc++ -static-libgcc -L$PREFIX/lib -lz"
fi

install -d ${PREFIX}/bin
install bin/ska ${PREFIX}/bin
