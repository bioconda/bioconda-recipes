#!/bin/bash
set -eu -o pipefail

# The project's Makefiles don't use {CPP,C,CXX,LD}FLAGS everywhere.
# We can try to patch all of those or export the following *_PATH variables.
export C_INCLUDE_PATH="${PREFIX}/include"
export CPLUS_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14"
export CFLAGS="${CFLAGS} -O3"

outdir="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
mkdir -p "$outdir"
mkdir -p "$outdir/scripts"
mkdir -p "$PREFIX/bin"

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* lib/htslib

# Avoid conflicts with C++20 
mv src/utils/gzstream/version src/utils/gzstream/version.txt

pushd src/utils/sqlite3
sed -i.bak "s#@gcc#${CC}#g" Makefile
popd

make CC="${CC}" \
	CXX="${CXX}" \
	CPPFLAGS="${CPPFLAGS}" \
	CFLAGS="${CFLAGS}" \
	CXXFLAGS="${CXXFLAGS}" \
	LDFLAGS="${LDFLAGS}" \
	ZLIB_PATH="${PREFIX}/lib" \
	-j"${CPU_COUNT}"

install -v -m 0755 bin/* "$PREFIX/bin"
