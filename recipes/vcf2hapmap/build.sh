#!/bin/bash

v2h=$PREFIX/opt/$PKG_NAME-$PKG_VERSION
mkdir -p $v2h
cp -r ./* $v2h
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $v2h/VCF2FastaAndHapmap.pl
rm -f $v2h/VCF2FastaAndHapma.bak
chmod +x $v2h/vcf2FastaAndHapmap.sh
chmod 777 $v2h/VCF2FastaAndHapmap.pl
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/opt/var
ln -s $v2h/vcf2FastaAndHapmap.sh $PREFIX/bin/vcf2FastaAndHapmap.sh
ln -s  $v2h/VCF2FastaAndHapmap.pl $PREFIX/bin/VCF2FastaAndHapmap.pl
