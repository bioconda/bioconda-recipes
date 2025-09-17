#!/bin/bash -xe

make -j ${CPU_COUNT} \
  CC="${CC}" \
  CFLAGS="${CFLAGS} -fcommon -g -Wall -Wc++-compat -O3" \
  LIBS="${LDFLAGS} -lz -lpthread -lm -fopenmp"

mkdir -p "${PREFIX}/bin"
chmod 0755 ropebwt3
mv ropebwt3 "${PREFIX}/bin/"
