#!/bin/bash

pushd src

make -f Makefile \
  CC="${CC}" \
  CFLAGS="${CFLAGS} -O2 -g -Wall -D__USE_FIXED_PROTOTYPES__" \
  LDFLAGS="${LDFLAGS}"

mkdir -p "${PREFIX}/bin"

cp \
  long_seq_tm_test \
  ntdpal \
  oligotm \
  primer3_core \
  "${PREFIX}/bin/"
