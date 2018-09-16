#!/bin/bash

make

cd bin
binaries="\
genomic_apps \
genomic_overlaps \
genomic_regions \
genomic_scans \
gtools_hic \
matrix \
permutation_test \
vectors \
"
for i in $binaries; do cp $i $PREFIX/bin/$i; done
for i in $binaries; do chmod +x $PREFIX/bin/$i; done