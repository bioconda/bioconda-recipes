#!/bin/bash

pep_scaffolder=$PREFIX/opt/$PKG_NAME-$PKG_VERSION
mkdir -p $pep_scaffolder
cp -r ./* $pep_scaffolder
chmod +x $pep_scaffolder/pep_scaffolder
mkdir -p $PREFIX/bin
ln -s $pep_scaffolder/pep_scaffolder $PREFIX/bin/pep_scaffolder
 
