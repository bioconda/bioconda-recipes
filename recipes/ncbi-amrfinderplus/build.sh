#!/bin/bash

make CXX="$CXX $LDFLAGS" CPPFLAGS="$CXXFLAGS" PREFIX="$PREFIX" DEFAULT_DB_DIR="$PREFIX/share/amrfinderplus/data"
make install
