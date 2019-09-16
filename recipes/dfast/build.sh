#!/bin/sh

APPROOT=$PREFIX/opt/$PKG_NAME-$PKG_VERSION

rm -rf bin/Linux
rm -rf bin/Darwin

mkdir -p $APPROOT
mkdir -o ${PREFIX}/bin
cp -r ./* $APPROOT

ln -s ${APPROOT}/dfast ${PREFIX}/bin/dfast
ln -s ${APPROOT}/scripts/file_downloader.py ${PREFIX}/bin/dfast_file_downloader.py
ln -s ${APPROOT}/scripts/file_downloader.py ${PREFIX}/bin/file_downloader.py
