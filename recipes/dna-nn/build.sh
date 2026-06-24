#!/bin/bash
set -x -e

export CPATH="${PREFIX}/include"

mkdir -p "${PREFIX}/bin"

sed -i.bak 's|-O2|-O3|' Makefile
sed -i.bak 's|-lpthread|-pthread|' Makefile
rm -rf *.bak

make CC="${CC}" -j"${CPU_COUNT}"

install -v -m 0755 dna-brnn dna-cnn gen-fq parse-rm.js "${PREFIX}/bin"
