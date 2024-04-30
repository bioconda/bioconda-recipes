#!/bin/bash

mkdir -p $PREFIX/bin

EXES="downloadKalamari.pl downloadKalamari.sh generate_sepia_reference.py  getExactTaxonomy.pl  mobsuiteRepresentativeFasta.pl  validateTaxonomy.pl"

for i in $EXES; do
  chmod -v 755 bin/$i
  cp -vf bin/$i $PREFIX/bin
done

# install and update locales (required for R to function properly)
#apt-get -y install locales
#LC_ALL=C.UTF-8
#dpkg-reconfigure locales
#echo 'export LC_ALL=C.UTF-8' >> ~/.bashrc

