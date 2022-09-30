#!/bin/bash

make \
  CC="${CC}" CPP="${CXX}" \
  CFLAG="${CFLAGS} \$(CCFLAGS) -std=gnu99" \
  CPPFLAGS="${CXXFLAGS} \$(CCFLAGS)" \
  LDFLAGS+=-pthread \
  BDIR="${PREFIX}/bin"
