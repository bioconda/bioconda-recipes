#!/bin/bash
mkdir build_spades
pushd build_spades
cmake -G "Unix Makefiles" \
      -DCMAKE_INSTALL_PREFIX="$PREFIX" \
      -DCMAKE_C_COMPILER=$CC \
      -DCMAKE_CXX_COMPILER=$CXX \
      -DCMAKE_CFLAGS="$CFLAGS" \
      -DCMAKE_CXXFLAGS="$CXXFLAGS" \
      ../src
make install
