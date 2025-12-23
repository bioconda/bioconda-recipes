#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "$PREFIX/bin"
mkdir -p "$PREFIX/share/${PKG_NAME}-${PKG_VERSION}"

make all -j"${CPU_COUNT}"

install -v -m 0755 bin/ribotin-ref bin/ribotin-verkko bin/ribotin-hifiasm "$PREFIX/bin"

cp -f template_seqs/rDNA_one_unit.fasta $PREFIX/share/${PKG_NAME}-${PKG_VERSION}/rDNA_one_unit.fasta
cp -f template_seqs/rDNA_one_unit.fasta.fai $PREFIX/share/${PKG_NAME}-${PKG_VERSION}/rDNA_one_unit.fasta.fai
cp -f template_seqs/chm13_rDNAs.fa $PREFIX/share/${PKG_NAME}-${PKG_VERSION}/chm13_rDNAs.fa
cp -f template_seqs/rDNA_annotation.gff3 $PREFIX/share/${PKG_NAME}-${PKG_VERSION}/rDNA_annotation.gff3
cp -f template_seqs/rDNA_annotation.gff3_db $PREFIX/share/${PKG_NAME}-${PKG_VERSION}/rDNA_annotation.gff3_db
