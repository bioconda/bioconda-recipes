#!/usr/bin/env bash

# install DAStool R package
R CMD INSTALL "$PREFIX/package/${PKG_NAME}_${PKG_VERSION}.tar.gz"

# unzip SCG marker database
unzip db.zip

# install DAS_Tool
DESTDIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $DESTDIR
cp DAS_Tool $DESTDIR
cp -r src db $DESTDIR
chmod +x $DESTDIR/DAS_Tool

ln -s $DESTDIR/DAS_Tool $PREFIX/bin/
