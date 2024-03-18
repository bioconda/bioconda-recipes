#!/bin/bash

mkdir -p $PREFIX/bin

EXES="downloadKalamari.pl  generate_sepia_reference.py  getExactTaxonomy.pl  mobsuiteRepresentativeFasta.pl  validateTaxonomy.pl"

for i in $EXES; do
  chmod -v 755 bin/$i
  cp -vf bin/$i $PREFIX/bin
done

