#!/bin/bash
set -euxo

# Patch
sed -i 's/^CC = gcc$/CC ?= gcc/' Makefile

# Compile the project
make

# Install the binaries
mkdir -p "$PREFIX/bin"
cp bin/* "$PREFIX/bin"
