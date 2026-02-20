#!/bin/bash

# Set compiler flags
export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include -Ihtslib/htslib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

# Patch Makefile for Bioconda compatibility
sed -i.bak 's|-std=gnu99|-std=c11 -I$(PREFIX)/include|' Makefile
sed -i.bak 's|-lpthread|-pthread|' Makefile
sed -i.bak 's|CLIB = -ltinfo|CLIB = -L$(PREFIX)/lib -ltinfo|' Makefile
if [[ "$(uname -s)" == "Darwin" ]]; then
  sed -i.bak 's/-ltinfo//g' Makefile
fi
rm -rf *.bak

# Build
make CC="${CC}" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" -j"${CPU_COUNT}"

# Install binary
mkdir -p "${PREFIX}/bin"
install -v -m 0755 yame "${PREFIX}/bin"

