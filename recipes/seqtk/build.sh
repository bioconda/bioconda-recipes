#!/bin/bash

mkdir -p "${PREFIX}/bin"
make \
  CC="${CC}" \
  CFLAGS="${CFLAGS}" \
  BINDIR="${PREFIX}/bin" \
  install
