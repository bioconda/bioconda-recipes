#!/bin/bash

# extract reference files from GG sub-archive
tar xjvf gg/sepp-package.tar.bz sepp-package/ref/

# delete two unused files
rm -v sepp-package/ref/reference-gg-raxml-bl.tre
rm -v sepp-package/ref/reference-gg-raxml-bl-rooted.tre

# create conda share directory
mkdir -p $PREFIX/share/sepp/ref/

# move reference files to conda location
cp -v sepp-package/ref/99_otu_taxonomy.txt $PREFIX/share/sepp/ref/
cp -v sepp-package/ref/gg_13_5_ssu_align_99_pfiltered.fasta $PREFIX/share/sepp/ref/
cp -v sepp-package/ref/RAxML_info-reference-gg-raxml-bl.info $PREFIX/share/sepp/ref/
cp -v sepp-package/ref/reference-gg-raxml-bl-rooted-relabelled.tre $PREFIX/share/sepp/ref/
