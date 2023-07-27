#!/usr/bin/env bash

cd $SRC_DIR
make all
cp bin/ribotin-ref $PREFIX/bin
cp bin/ribotin-verkko $PREFIX/bin

mkdir $PREFIX/share/ribotin_template_seqs
cp template_seqs/rDNA_one_unit.fasta $PREFIX/share/ribotin_template_seqs/rDNA_one_unit.fasta
cp template_seqs/chm13_rDNAs.fa $PREFIX/share/ribotin_template_seqs/chm13_rDNAs.fa
