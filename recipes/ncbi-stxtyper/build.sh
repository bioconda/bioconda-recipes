#!/bin/bash

set -xe

# fix error because of gnu++17 features. Suggested by https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
# CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

echo
echo "Starting build.sh"
echo
echo "SRC_DIR=$SRC_DIR"
echo "pwd -P"
pwd -P
echo "ls -l"
ls -l

ARCH=$(uname -m)
if [[ "${ARCH}" == "aarch64" ]]; then
    CXXFLAGS="${CXXFLAGS} -fsigned-char"
fi

# note that for version 3.7 the make command should be:
make -j"${CPU_COUNT}" CXX="$CXX $LDFLAGS" CPPFLAGS="$CXXFLAGS" PREFIX="$PREFIX" 

#echo "make CXX=\"$CXX $LDFLAGS\" CPPFLAGS=\"$CXXFLAGS\" PREFIX=\"$PREFIX\" DEFAULT_DB_DIR=\"$PREFIX/share/amrfinderplus/data\""

#make CXX="$CXX $LDFLAGS" CPPFLAGS="$CXXFLAGS" PREFIX=$PREFIX DEFAULT_DB_DIR="$PREFIX/share/amrfinderplus/data"
make install bindir=$PREFIX/bin

echo "build.sh done"
