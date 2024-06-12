#!/bin/sh

set -x -e -o pipefail

make \
  CXX="${CXX} -std=c++11" \
  CXX_FLAGS="${CXXFLAGS} -I${PREFIX}/include -g -Wall -O3 ${LDFLAGS}"

mkdir -p "${PREFIX}/bin"

cp bin/callerpp "${PREFIX}/bin/"
