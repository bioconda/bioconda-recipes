#!/bin/sh
make
mkdir -p $PREFIX/bin
mv bowtie $PREFIX/bin
mv bowtie-build $PREFIX/bin
mv bowtie-inspect $PREFIX/bin
