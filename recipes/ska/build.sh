#!/bin/bash

make CXX="$CXX" CXXFLAGS="$CXXFLAGS" LDFLAGS="-L$PREFIX/lib -lz"

install -d ${PREFIX}/bin
install bin/ska ${PREFIX}/bin
