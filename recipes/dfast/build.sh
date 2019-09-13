#!/bin/sh

APPROOT=$PREFIX/opt/$PKG_NAME-$PKG_VERSION

rm -rf bin/Linux
rm -rf bin/Darwin

mkdir -p $APPROOT
cp -r ./* $APPROOT

ln -s ${APPROOT}/dfast ${PREFIX}/bin/dfast
ln -s ${APPROOT}/scripts/dfast_file_downloader.py ${PREFIX}/bin/dfast_file_downloader.py
