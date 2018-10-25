#!/bin/bash

make CXX="$CXX" CXXFLAGS="$CXXFLAGS" LDFLAGS="$LDFLAGS -lz"
install -d ${PREFIX}/bin
install bin/ska ${PREFIX}/bin
