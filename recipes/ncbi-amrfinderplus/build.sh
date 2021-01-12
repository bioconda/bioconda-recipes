#!/bin/bash

echo "DEBUGGING environment info because PREFIX did not appear to be set"
echo "PREFIX=$PREFIX    CONDA_PREFIX=$CONDA_PREFIX"
echo "PREFIX =" $PREFIX CONDA_PREFIX = $CONDA_PREFIX BUILD_PREFIX = $BUILD_PREFIX
echo $PREFIX

# test fix for version 3.9.8
# move patch to meta.yaml
# patch < patch.3.9.8

# note that for version 3.7 the make command should be:
make CXX="$CXX $LDFLAGS" CPPFLAGS="$CXXFLAGS" PREFIX="$PREFIX" CONDA_DB_DIR="$CONDA_PREFIX/share/amrfinderplus/data"

#echo "make CXX=\"$CXX $LDFLAGS\" CPPFLAGS=\"$CXXFLAGS\" PREFIX=\"$PREFIX\" DEFAULT_DB_DIR=\"$PREFIX/share/amrfinderplus/data\""

#make CXX="$CXX $LDFLAGS" CPPFLAGS="$CXXFLAGS" PREFIX=$PREFIX DEFAULT_DB_DIR="$PREFIX/share/amrfinderplus/data"
make install bindir=$PREFIX/bin
