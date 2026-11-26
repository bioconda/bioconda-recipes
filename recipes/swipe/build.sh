#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

install -d "${PREFIX}/bin"

if [[ "$(uname -m)" == "aarch64" || "$(uname -m)" == "arm64" ]]; then
  git clone https://github.com/DLTcollab/sse2neon.git
  cp -f sse2neon/sse2neon.h ./
  sed -i.bak 's|#include <x86intrin.h>|#include "sse2neon.h"|' swipe.h
  rm -f *.bak
fi

make CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}" -j"${CPU_COUNT}"

install -v -m 0755 swipe "${PREFIX}/bin"
