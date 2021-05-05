#!/bin/bash

set -e

# export CPATH=${PREFIX}/include

mkdir -p $PREFIX/bin

make
chmod +x metacache download-ncbi-genomes download-ncbi-taxmaps download-ncbi-taxonomy metacache-build-refseq metacache-db-info metacache-partition-genomes summarize-results
mv metacache $PREFIX/bin
mv download-ncbi-genomes $PREFIX/bin
mv download-ncbi-taxmaps $PREFIX/bin
mv download-ncbi-taxonomy $PREFIX/bin
mv metacache-build-refseq $PREFIX/bin
mv metacache-db-info $PREFIX/bin
mv metacache-partition-genomes $PREFIX/bin
mv summarize-results $PREFIX/bin
