#!/bin/bash

# This will run your existing Makefile.
# conda-build automatically sets up the environment so that the
# C compiler ($CC) is found and the htslib headers and libraries
# are available for compilation and linking.
make PREFIX=$PREFIX

# Create the directory where executables should be placed in a conda env
mkdir -p $PREFIX/bin

# Copy your compiled unicorn executable into that directory
cp unicorn $PREFIX/bin/

# Optional: If you want to install header files for others to use
mkdir -p $PREFIX/include
cp src/unicorn.h $PREFIX/include/

# Optional: If you want to install the static library
mkdir -p $PREFIX/lib
cp libunicorn.a $PREFIX/lib/
