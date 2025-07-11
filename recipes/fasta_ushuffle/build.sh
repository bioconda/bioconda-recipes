#!/bin/bash

mkdir -p ${PREFIX}/bin

sed -i.bak 's|gcc|$(CC)|' Makefile
sed -i.bak 's|-O1|-O3|' Makefile
rm -rf *.bak

make CC="${CC}" -j"${CPU_COUNT}"
install -v -m 0755 fasta_ushuffle ushuffle "${PREFIX}/bin"
