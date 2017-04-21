#!/bin/bash
set -eu

# Create a folder
mkdir -p $PREFIX/bin

cd src
make -f Makefile.Linux
chmod a+x ../bin/featureCounts
cp ../bin/featureCounts $PREFIX/bin/
