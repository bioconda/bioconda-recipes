#!/bin/bash

sed -i.bak 's/\$(CFLAGS)/$(CPPFLAGS) $(CFLAGS) $(LDFLAGS)/' Makefile
mkdir -p "${PREFIX}/bin"
make \
  CC="${CC}" \
  CPPFLAGS="${CPPFLAGS}" \
  CFLAGS="${CFLAGS}" \
  LDFLAGS="${CFLAGS}" \
  BINDIR="${PREFIX}/bin" \
  install
