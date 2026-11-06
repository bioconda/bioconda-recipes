#!/bin/sh

APPROOT=$PREFIX/opt/$PKG_NAME-$PKG_VERSION

# Since DFAST 1.5, only MGA (mga, mga_4) and CRT are bundled. mga comes from metagene_annotator.
rm bin/*/mga
if [ "$(uname)" == "Darwin" ]; then
    rm -rf bin/Linux
else
    rm -rf bin/Darwin
fi


mkdir -p $APPROOT
mkdir -p ${PREFIX}/bin

cp -r ./* $APPROOT

ln -s ${APPROOT}/dfast ${PREFIX}/bin/dfast
ln -s ${APPROOT}/scripts/dfast_file_downloader.py ${PREFIX}/bin/dfast_file_downloader.py
ln -s ${APPROOT}/scripts/file_downloader.py ${PREFIX}/bin/file_downloader.py
