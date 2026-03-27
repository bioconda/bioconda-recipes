#!/bin/bash
set -ex

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/share/snap
mkdir -p ${PREFIX}/share/snap/bin

export C_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

make CC="${CC}" -j"${CPU_COUNT}"

for perl_script in gff3_to_zff.pl hmm-assembler.pl zff2gff3.pl; do
	sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${perl_script}
done
rm -rf *.bak

install -v -m 0755 snap fathom forge gff3_to_zff.pl hmm-assembler.pl zff2gff3.pl $PREFIX/share/snap/bin
cp -prf HMM ${PREFIX}/share/snap
cp -prf DNA ${PREFIX}/share/snap
cp -prf DATA ${PREFIX}/share/snap

ln -sf $PREFIX/share/snap/bin/* ${PREFIX}/bin/
