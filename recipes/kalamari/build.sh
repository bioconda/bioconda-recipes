#!/bin/bash

mkdir -p $PREFIX/bin

# Add in the correct version for the build
sed -i.bak "s/VERSION=.\+/VERSION=\"${PKG_VERSION}\"/" bin/downloadKalamari.sh

EXES="downloadKalamari.pl downloadKalamari.sh generate_sepia_reference.py  getExactTaxonomy.pl  mobsuiteRepresentativeFasta.pl  validateTaxonomy.pl"

for i in $EXES; do
  chmod -v 755 bin/$i
  cp -vf bin/$i $PREFIX/bin
done
