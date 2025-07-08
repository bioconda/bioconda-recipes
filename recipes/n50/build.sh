#!/bin/bash
set -euxo pipefail

# Patch
sed -i 's/^CC = gcc$/CC ?= gcc/' Makefile

# CPPFLAGS is PERFECT for include directories in C programs
export CPPFLAGS="$CPPFLAGS -I$BUILD_PREFIX/include"
sed -i 's/$(CC) $(CFLAGS)/$(CC) $(CPPFLAGS) $(CFLAGS)/g' Makefile


make

./bin/n50 --version

# Install the binaries
mkdir -p "$PREFIX/bin"
cp -v bin/* "$PREFIX/bin"
