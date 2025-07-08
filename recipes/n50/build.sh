#!/bin/bash
set -euxo

# Patch
sed -i 's/^CC = gcc$/CC ?= gcc/' Makefile

# Explicitly set include/library paths
export CFLAGS="$CFLAGS -I$BUILD_PREFIX/include"
export LDFLAGS="$LDFLAGS -L$BUILD_PREFIX/lib""
export CPATH="$BUILD_PREFIX/include"

# Compile the project
make CC="$CC"

# Install the binaries
mkdir -p "$PREFIX/bin"
cp -v bin/* "$PREFIX/bin"
