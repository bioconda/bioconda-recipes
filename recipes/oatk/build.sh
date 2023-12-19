#!/bin/bash

# Explicitly setting library paths for zlib
export CPATH=${PREFIX}/include

# Use Conda environment variables for the C compiler and flags
make CC=$CC CFLAGS="$CFLAGS"
ls -la

# Copying binaries to the $PREFIX/bin directory for them to be included in the Conda package
mkdir -p $PREFIX/bin

if [ -f oatk ]; then cp oatk $PREFIX/bin/; fi
if [ -f path_to_fasta ]; then cp path_to_fasta $PREFIX/bin/; fi
if [ -f pathfinder ]; then cp pathfinder $PREFIX/bin/; fi
if [ -f hmm_annotation ]; then cp hmm_annotation $PREFIX/bin/; fi
if [ -f syncasm ]; then cp syncasm $PREFIX/bin/; fi

