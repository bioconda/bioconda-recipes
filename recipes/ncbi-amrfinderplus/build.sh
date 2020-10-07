#!/bin/bash
echo "PREFIX=$PREFIX    CONDA_PREFIX=$CONDA_PREFIX"
set
# note that for version 3.7 the make command should be:
make CXX="$CXX $LDFLAGS" CPPFLAGS="$CXXFLAGS" PREFIX="$PREFIX" CONDA_DB_DIR="$CONDA_PREFIX/share/amrfinderplus/data"

# make CXX="$CXX $LDFLAGS" CPPFLAGS="$CXXFLAGS" PREFIX="$PREFIX" DEFAULT_DB_DIR="$PREFIX/share/amrfinderplus/data"
make install bindir=$PREFIX/bin
