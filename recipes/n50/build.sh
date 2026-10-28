#!/bin/bash
set -euxo pipefail

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

mkdir -p "${PREFIX}/bin"

# Patch
sed -i.bak 's/^CC = gcc$/CC ?= gcc/' Makefile
sed -i.bak 's|-lpthread|-pthread|' Makefile

# CPPFLAGS is PERFECT for include directories in C programs
sed -i.bak 's/$(CC) $(CFLAGS)/$(CC) $(CPPFLAGS) $(CFLAGS)/g' Makefile
rm -rf *.bak

make CC="${CC}" -j"${CPU_COUNT}"

./bin/n50 --version

# Install the binaries
install -v -m 0755 bin/* "${PREFIX}/bin"
