#!/bin/bash

LIBS='-pthread -lhdf5 -lhdf5_hl -ldivsufsort64 -lbz2 -llzma -lz -ldl -lm'

if [ "$(uname)" = Darwin ]; then
  makefile=Makefile_mac
else
  makefile=Makefile_linux
  LIBS="-lrt ${LIBS}"
fi

make -f "${makefile}" CC="${CC}" CFLAGS+=' -fcommon -fgnu89-inline -O2 -w' LIBS="${LDFLAGS} ${LIBS}"

cd build
mkdir -p "${PREFIX}/bin"
cp hera hera_build "${PREFIX}/bin/"
