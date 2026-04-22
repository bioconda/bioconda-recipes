#!/bin/bash
set -ex

export C_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

mkdir -p "${PREFIX}/bin"
mkdir -p bin

if [[ "$(uname -s)" == "Darwin" ]]; then
  sed -i.bak 's|-lnick -pthread|-lnick -pthread -largp|' src/Makefile
fi

sed -i.bak 's|TOP=../bin|TOP=$(PREFIX)/bin|' src/Makefile
rm -rf src/*.bak

# clear out pre-built objects and executables
cd src

make clobber CC="${CC}" -j"${CPU_COUNT}"

make all CC="${CC}" -j"${CPU_COUNT}"

make install CC="${CC}"
