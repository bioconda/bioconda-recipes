#!/bin/bash

make CXX="$CXX $LDFLAGS" CPPFLAGS="$CXXFLAGS" PREFIX="$PREFIX" prefix="$PREFIX" INSTALL_DIR="$PREFIX/bin"
make install
