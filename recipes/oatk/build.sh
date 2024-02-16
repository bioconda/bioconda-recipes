#!/bin/bash

# Use Conda environment variables for the C compiler and flags
make CC=$CC CFLAGS="$CFLAGS $LDFLAGS"
ls -la

# Copying binaries to the $PREFIX/bin directory for them to be included in the Conda package
mkdir -p $PREFIX/bin

cp oatk path_to_fasta pathfinder hmm_annotation syncasm $PREFIX/bin/

