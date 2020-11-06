#!/bin/bash

mkdir -p $PREFIX/bin

constax=$PREFIX/opt/$PKG_NAME-$PKG_VERSION
mkdir -p $constax
echo "export SINTAXPATH=vsearch" > $constax/pathfile.txt
echo "export RDPPATH=classifier" >> $constax/pathfile.txt
echo "export CONSTAXPATH=$constax" >> $constax/pathfile.txt
cp -r ./* $constax
chmod +x $constax/constax.sh
chmod +x $constax/fasta_select_by_keyword.py

mkdir -p $PREFIX/bin
ln -s $constax/constax.sh $PREFIX/bin/constax
ln -s $constax/fasta_select_by_keyword.py $PREFIX/bin/fasta_select_by_keyword.py
