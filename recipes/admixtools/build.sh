#!/bin/bash
set -ex

export C_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

mkdir -p "${PREFIX}/bin"

# clear out pre-built objects and executables
cd src

if [[ "$(uname -s)" == "Linux" ]]; then
  make clobber CC="${CC}" -j"${CPU_COUNT}"
  make all CC="${CC}" -j"${CPU_COUNT}"
  make install CC="${CC}" TOP="${PREFIX}/bin"
else
  make clobber -f Makefile.mac CC="${CC}" -j"${CPU_COUNT}"
  make all -f Makefile.mac CC="${CC}" -j"${CPU_COUNT}"
  make install -f Makefile.mac CC="${CC}" TOP="${PREFIX}/bin"
fi
