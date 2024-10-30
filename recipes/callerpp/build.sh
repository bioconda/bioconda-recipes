#!/bin/sh

set -x -e -o pipefail

case $(uname -m) in
  aarch64) 
    ARCH_OPTS="-fsigned-char"
    ;;
  *)
    ARCH_OPTS=""
    ;;
esac

make \
  CXX="${CXX} -std=c++11 ${ARCH_OPTS}" \
  CXX_FLAGS="${CXXFLAGS} -I${PREFIX}/include -g -Wall -O3 ${LDFLAGS}"

mkdir -p "${PREFIX}/bin"

cp bin/callerpp "${PREFIX}/bin/"
