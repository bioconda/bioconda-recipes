#!/usr/bin/env bash

# Skip copying of bwa, minimap2, and samtools
sed -i.backup \
    -e "s| bwa samtools minimap2||g" \
    Makefile

# Use conda's gcc and includes, also skip build of bwa, minimap2, and samtools
sed -i.backup \
    -e "s| bwa_ samtools_ minimap2_||g" \
    -e "s|gcc|$CC|g" \
    -e "s|-lz|-lz -isystem ${PREFIX}/include|g" \
    util/Makefile

# Build
make
mkdir ${PREFIX}/bin
cp bin/* ${PREFIX}/bin
