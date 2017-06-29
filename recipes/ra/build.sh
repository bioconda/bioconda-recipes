#!/bin/bash

mkdir -p $PREFIX/bin

make


binaries="\
consensus \
depot \
fill_read_coverage \
filter_contained \
filter_erroneous_overlaps \
filter_transitive \
overlap2dot \
ra_consensus \
to_afg \
unitigger \
widen_overlaps \ 
zoom \
"

for i in $binaries; do cp bin/release/$i $PREFIX/bin && chmod +x $PREFIX/bin/$i; done
