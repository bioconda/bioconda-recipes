#!/bin/sh

APPROOT=$PREFIX/opt/$PKG_NAME-$PKG_VERSION

# Since DFAST 1.6, no executables are bundled; all external programs are dependencies.
mkdir -p $APPROOT
mkdir -p ${PREFIX}/bin

cp -r ./* $APPROOT

ln -s ${APPROOT}/dfast ${PREFIX}/bin/dfast
ln -s ${APPROOT}/scripts/dfast_file_downloader.py ${PREFIX}/bin/dfast_file_downloader.py
ln -s ${APPROOT}/scripts/file_downloader.py ${PREFIX}/bin/file_downloader.py
ln -s ${APPROOT}/scripts/reference_util.py ${PREFIX}/bin/reference_util.py
ln -s ${APPROOT}/scripts/reference_util_for_nucl.py ${PREFIX}/bin/reference_util_for_nucl.py
