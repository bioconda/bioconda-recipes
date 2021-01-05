#!/bin/bash

make \
  CC="${CC}" \
  installDir="${PREFIX}/bin" \
  definedForAll="${CFLAGS} -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE" \
  install
