#!/bin/bash
set -eu -o pipefail

# The project's Makefiles don't use {CPP,C,CXX,LD}FLAGS everywhere.
# We can try to patch all of those or export the following *_PATH variables.
export C_INCLUDE_PATH="${PREFIX}/include"
export CPLUS_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export ZLIB_PATH="${PREFIX}/lib/"

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $outdir/scripts
mkdir -p $PREFIX/bin

pushd src/utils/sqlite3
sed -i.bak "s#@gcc#${CC}#g" Makefile
popd

make \
    CC="${CC}" \
    CXX="${CXX}" \
    CPPFLAGS="${CPPFLAGS}" \
    CFLAGS="${CFLAGS}" \
    CXXFLAGS="${CXXFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    ZLIB_PATH="${PREFIX/lib}"

cp bin/* $PREFIX/bin
