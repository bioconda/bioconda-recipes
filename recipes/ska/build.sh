#!/bin/bash

make CXX="$CXX" CXXFLAGS="$CXXFLAGS" LDFLAGS="$LDFLAGS -lz"
make install
