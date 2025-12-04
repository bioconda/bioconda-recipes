#!/bin/bash
set -eu -o pipefail

mkdir -p "$PREFIX/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

if [[ $OSTYPE == "darwin"* ]]; then
  LDFLAGS="${LDFLAGS} -lc"
fi

make DIR_INC="$PREFIX/include" LDFLAGS="${LDFLAGS}" CC="${CXX}" -j"${CPU_COUNT}"

install -v -m 0755 genefuse "$PREFIX/bin"
