#!/bin/bash

mkdir -p $PREFIX/bin

# Dont' read the default CXXFLAGS, as the build doesn't work with -O2.
export CXXFLAGS="-g -gdwarf-3 -fpermissive -Wall -O0 -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

make VERBOSE=1
install -m 755 pstools $PREFIX/bin/
