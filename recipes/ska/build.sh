#!/bin/bash

make CXX="$CXX" CXXFLAGS="$CXXFLAGS" LDFLAGS="-static -static-libstdc++ -static-libgcc -L$PREFIX/lib -lz"
install -d ${PREFIX}/bin
install bin/ska ${PREFIX}/bin
