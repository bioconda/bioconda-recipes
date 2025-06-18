#!/bin/bash

mkdir -p "${PREFIX}/bin"

sed -i.bak 's|-lpthread|-pthread|' Makefile
sed -i.bak 's|gcc|$(CC)|' Makefile
sed -i.bak 's|-Wall|-O3 -Wall|' Makefile
rm -rf *.bak

make CC="${CC}" PREFIX="${PREFIX}" --file=makefile-conda.mk -j"${CPU_COUNT}"

install -v -m 755 cvlr-cluster cvlr-meth-of-bam *py "${PREFIX}/bin"
