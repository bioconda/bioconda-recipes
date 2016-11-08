#!/bin/bash

mkdir -p $PREFIX/etc/conda/activate.d/
echo "export JBROWSE_SOURCE_DIR=$PREFIX/opt/jbrowse" > $PREFIX/etc/conda/activate.d/jbrowse-sourcedir.sh
chmod a+x $PREFIX/etc/conda/activate.d/jbrowse-sourcedir.sh

mkdir -p $PREFIX/etc/conda/deactivate.d/
echo "unset JBROWSE_SOURCE_DIR" > $PREFIX/etc/conda/deactivate.d/jbrowse-sourcedir.sh
chmod a+x $PREFIX/etc/conda/deactivate.d/jbrowse-sourcedir.sh

cd $SRC_DIR

mkdir -p $PREFIX/bin/
cp bin/*.pl $PREFIX/bin/
chmod a+x $PREFIX/bin/*.pl
sed -i.bak 's|../src/perl5|../opt/jbrowse/src/perl5|g' $PREFIX/bin/*.pl
rm $PREFIX/bin/*.pl.bak

mkdir -p $PREFIX/opt/jbrowse/
cp -r * $PREFIX/opt/jbrowse/
