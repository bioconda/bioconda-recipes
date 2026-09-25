#!/bin/bash

mkdir -p "${PREFIX}/bin"

sed -i.bak 's|-lpthread|-pthread|' Makefile
sed -i.bak 's|gcc|$(CC)|' Makefile
sed -i.bak 's|-Wall|-Wall -O3|' Makefile
rm -rf *.bak

make PREFIX="${PREFIX}" -j"${CPU_COUNT}" --file="makefile-conda.mk"

install -v -m 755 cvlr-cluster cvlr-meth-of-bam *py "${PREFIX}/bin"
