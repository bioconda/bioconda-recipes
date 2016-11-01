#!/bin/bash

mkdir -p $PREFIX/etc/conda/activate.d/
echo "export JBROWSE_SOURCE_DIR=$PREFIX/opt/jbrowse" > $PREFIX/etc/conda/activate.d/jbrowse-sourcedir.sh
chmod a+x $PREFIX/etc/conda/activate.d/jbrowse-sourcedir.sh

mkdir -p $PREFIX/etc/conda/deactivate.d/
echo "unset JBROWSE_SOURCE_DIR" > $PREFIX/etc/conda/deactivate.d/jbrowse-sourcedir.sh
chmod a+x $PREFIX/etc/conda/deactivate.d/jbrowse-sourcedir.sh

cd $SRC_DIR

mkdir -p $PREFIX/bin/
cp bin/* $PREFIX/bin/
chmod a+x $PREFIX/bin/*
sed -i.bak 's|../src/perl5|../opt/jbrowse/src/perl5|g' $PREFIX/bin/*

mkdir -p $PREFIX/opt/jbrowse/
cp -r * $PREFIX/opt/jbrowse/
