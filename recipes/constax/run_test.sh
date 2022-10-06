#!/bin/bash -login

constax=$PREFIX/opt/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

$PREFIX/bin/constax -c 0.8 -b -t -i $constax/test_data/silva_test_query.fasta -n 4 -d $constax/test_data/silva_test_ref.fasta -f tf_test_sil -x tax_test_sil -o out_test_sil \
  --mem 4000 -m 1 --isolates $constax/test_data/silva_test_isos.fasta --conservative --pathfile $constax/pathfile.txt > /dev/null 2>&1

$PREFIX/bin/constax -c 0.8 -b -t -i $constax/test_data/unite_test_query.fasta -n 4 -d $constax/test_data/unite_test_ref.fasta -f tf_test_uni -x tax_test_uni -o out_test_uni \
  --mem 4000 -m 1 --isolates $constax/test_data/unite_test_isos.fasta --pathfile $constax/pathfile.txt > /dev/null 2>&1
