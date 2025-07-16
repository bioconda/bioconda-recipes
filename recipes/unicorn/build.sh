#!/bin/bash

# Create the directory where executables should be placed in a conda env
mkdir -p "$PREFIX/bin"
# Optional: If you want to install header files for others to use
mkdir -p "$PREFIX/include"
# Optional: If you want to install the static library
mkdir -p "$PREFIX/lib"

# This will run your existing Makefile.
# conda-build automatically sets up the environment so that the
# C compiler ($CC) is found and the htslib headers and libraries
# are available for compilation and linking.
make CC="${CC}" PREFIX="${PREFIX}" -j"${CPU_COUNT}"

# Copy your compiled unicorn executable into that directory
install -v -m 0755 unicorn "$PREFIX/bin"

cp -f src/unicorn.h "$PREFIX/include"

cp -f libunicorn.a "$PREFIX/lib"
