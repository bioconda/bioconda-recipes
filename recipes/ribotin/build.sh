#!/usr/bin/env bash

set -xe

make -j"${CPU_COUNT}" all

mkdir -p ${PREFIX}/bin
install -v -m 0755 bin/ribotin-ref $PREFIX/bin
install -v -m 0755 bin/ribotin-verkko $PREFIX/bin
install -v -m 0755 bin/ribotin-hifiasm $PREFIX/bin

mkdir -p $PREFIX/share/${PKG_NAME}-${PKG_VERSION}
cp template_seqs/rDNA_one_unit.fasta $PREFIX/share/${PKG_NAME}-${PKG_VERSION}/rDNA_one_unit.fasta
cp template_seqs/rDNA_one_unit.fasta.fai $PREFIX/share/${PKG_NAME}-${PKG_VERSION}/rDNA_one_unit.fasta.fai
cp template_seqs/chm13_rDNAs.fa $PREFIX/share/${PKG_NAME}-${PKG_VERSION}/chm13_rDNAs.fa
cp template_seqs/rDNA_annotation.gff3 $PREFIX/share/${PKG_NAME}-${PKG_VERSION}/rDNA_annotation.gff3
cp template_seqs/rDNA_annotation.gff3_db $PREFIX/share/${PKG_NAME}-${PKG_VERSION}/rDNA_annotation.gff3_db
