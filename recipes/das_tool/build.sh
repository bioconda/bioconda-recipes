#!/usr/bin/env bash

# install DAStool R package
R CMD INSTALL "package/DASTool_${PKG_VERSION}.tar.gz"

# unzip SCG marker database
unzip db.zip -d db

# install DAS_Tool
DESTDIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $DESTDIR
cp DAS_Tool $DESTDIR
cp -r src db $DESTDIR
chmod +x $DESTDIR/DAS_Tool

ln -s $DESTDIR/DAS_Tool $PREFIX/bin/
ln -s $DESTDIR/src/Fasta_to_Scaffolds2Bin.sh $PREFIX/bin/
