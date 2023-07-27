#!/usr/bin/env bash

cd $SRC_DIR
make all
cp bin/ribotin-ref $PREFIX/bin
cp bin/ribotin-verkko $PREFIX/bin

mkdir -p $PREFIX/share/${PKG_NAME}-${PKG_VERSION}
cp template_seqs/rDNA_one_unit.fasta $PREFIX/share/${PKG_NAME}-${PKG_VERSION}/rDNA_one_unit.fasta
cp template_seqs/chm13_rDNAs.fa $PREFIX/share/${PKG_NAME}-${PKG_VERSION}/chm13_rDNAs.fa
