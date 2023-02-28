#!/bin/bash

# extract Silva reference files
tar xjvf silva/sepp-package-silva.tar.bz sepp-package-silva/ref/
tar xjvf silva/sepp-package-silva-2.tar.bz sepp-package-silva/ref/

# create conda share directory
mkdir -p $PREFIX/share/sepp/ref/

# convert non-default Silva reference into qiime2 artifacts
mv -v sepp-package-silva/ref/RAxML_info.99_otus_aligned_masked1977.fasta $PREFIX/share/sepp/ref/
mv -v sepp-package-silva/ref/reference-99_otus_aligned_masked1977.fasta-rooted.tre $PREFIX/share/sepp/ref/
mv -v sepp-package-silva/ref/99_otus_aligned_masked1977.fasta $PREFIX/share/sepp/ref/
