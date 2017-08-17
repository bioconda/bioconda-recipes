 #!/bin/bash

snmf=$PREFIX/opt/snmf/
mkdir -p $snmf
mkdir -p $PREFIX/bin/
cp -rf ./* $snmf/
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $snmf/Snmf.pl
rm -f $snmf/Snmf.bak
chmod +x $snmf/snmf.sh
chmod +x $snmf/plink
chmod +x $snmf/Snmf.pl
ln -s $snmf/snmf.sh $PREFIX/bin/
