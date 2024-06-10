#!/bin/sh

set -x -e -o pipefail

make \
  CXX="${CXX}" \
  CXX_FLAGS="${CXX_FLAGS} -g -Wall -O3 ${LDFLAGS}"

mkdir -p "${PREFIX}/bin"

cp bin/callerpp "${PREFIX}/bin/"
