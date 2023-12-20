#!/usr/bin/env bash

# unzip SCG marker database
unzip db.zip -d db

# install DAS_Tool
DESTDIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $DESTDIR
cp DAS_Tool $DESTDIR
cp -r src db $DESTDIR
chmod +x $DESTDIR/DAS_Tool

ln -s $DESTDIR/DAS_Tool $PREFIX/bin/
ln -s $DESTDIR/src/Fasta_to_Contig2Bin.sh $PREFIX/bin/
ln -s $DESTDIR/src/Contigs2Bin_to_Fasta.sh $PREFIX/bin/
