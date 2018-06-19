#!/bin/bash
set -euo pipefail

# Set up zlib and bzip2 libraries
mkdir zlib
cd zlib
ln -s $PREFIX/include/zlib.h
ln -s $PREFIX/include/zconf.h
ln -s $PREFIX/lib/libz.a
cd ..
mkdir bzip2
cd bzip2
ln -s $PREFIX/include/bzlib.h
ln -s $PREFIX/lib/libbz2.a
# Move to src and build
cd ../src
make -f Makefile.static
# Manually copy vsearch exe
cp vsearch $PREFIX/bin
