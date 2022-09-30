#!/bin/sh
make
mkdir $PREFIX/bin
mv bowtie $PREFIX/bin
mv bowtie-build $PREFIX/bin
mv bowtie-inspect $PREFIX/bin
