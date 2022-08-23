#!/usr/bin/env bash

sed -i.backup \
    -e "s| bwa_ samtools_ minimap2_||g" \
    -e "s|gcc|$CC|g" \
    -e "s|-lz|-lz -isystem ${PREFIX}/include|g" \
    util/Makefile

make
mkdir ${PREFIX}/bin
cp bin/* ${PREFIX}/bin
