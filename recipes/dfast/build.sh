#!/bin/sh

APPROOT=$PREFIX/opt/$PKG_NAME-$PKG_VERSION
mkdir -p $APPROOT
cp -r ./* $APPROOT

ln -s ${APPROOT}/dfast ${PREFIX}/bin/
ln -s ${APPROOT}/scripts/file_downloader.py ${PREFIX}/bin/dfast_file_downloader.py
ln -s ${APPROOT}/scripts/file_downloader.py ${PREFIX}/bin
