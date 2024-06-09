#!/bin/sh

set -x -e -o pipefail

make \
  CC="${CC}" \
  CFLAGS="${CPPFLAGS} ${CFLAGS} -g -Wall -O3 ${LDFLAGS}"

mkdir -p "${PREFIX}/bin"

cp bin/callerpp "${PREFIX}/bin/"
