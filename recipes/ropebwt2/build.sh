#!/bin/bash

make \
  CC="${CC}" \
  CFLAGS="${CFLAGS} -fcommon -g -Wall -O2" \
  LIBS="${LDFLAGS} -lz -lpthread"

mkdir -p "${PREFIX}/bin"
mv ropebwt2 "${PREFIX}/bin/"
