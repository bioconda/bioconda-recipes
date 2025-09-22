#!/usr/bin/env bash
set -euo pipefail

mkdir -p "${PREFIX}/bin"

export CXXFLAGS="${CXXFLAGS} -std=c++11 -stdlib=libc++ -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

# use an older version of clang for macs
if [[ "$(uname)" == "Darwin" ]]; then
    export CC=clang-17 CXX=clang++-17
fi

./waf configure build install \
      --prefix=${PREFIX} \
      --bindir=${PREFIX}/bin \
      --libdir=${PREFIX}/lib \
      --jobs=${CPU_COUNT} \
      CFLAGS="${CFLAGS} -I${PREFIX}/include -I${PREFIX}/include/boost" \
      LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"