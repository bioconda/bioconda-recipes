#!/bin/bash

mkdir -p $PREFIX/bin

EXES="downloadKalamari.pl  generate_sepia_reference.py  getExactTaxonomy.pl  mobsuiteRepresentativeFasta.pl  validateTaxonomy.pl"

chmod -v 755 $EXES
cp -f $EXES $PREFIX/bin/

