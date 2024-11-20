#!/bin/bash

set -xe

make -j ${CPU_COUNT} \
  CC="${CC}" \
  CFLAGS="${CFLAGS} -fcommon -g -Wall -O2" \
  LIBS="${LDFLAGS} -lz -lpthread"

mkdir -p "${PREFIX}/bin"
mv ropebwt2 "${PREFIX}/bin/"
