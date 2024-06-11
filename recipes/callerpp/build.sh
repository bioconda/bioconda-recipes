#!/bin/sh

set -x -e -o pipefail

make \
  INCLUDES="${INCLUDES}" \
  LIBS="${LIBPATH}" \
  CXX="${CXX} -std=c++11" \
  CXX_FLAGS="${CXXFLAGS} -I${PREFIX}/include -L${PREFIX}/lib -g -Wall -O2 ${LDFLAGS}"

mkdir -p "${PREFIX}/bin"

cp bin/callerpp "${PREFIX}/bin/"
