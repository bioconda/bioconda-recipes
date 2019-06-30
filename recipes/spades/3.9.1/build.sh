#!/bin/bash
mkdir build_spades
pushd build_spades
cmake -G "Unix Makefiles" \
      -DCMAKE_INSTALL_PREFIX="$PREFIX" \
      -DCMAKE_C_COMPILER="$CC $CFLAGS" \
      -DCMAKE_CXX_COMPILER="$CXX $CXXFLAGS" \
      ../src
make install
