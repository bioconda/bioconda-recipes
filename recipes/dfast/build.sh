#!/bin/sh

APPROOT=$PREFIX/opt/$PKG_NAME-$PKG_VERSION
mkdir -p $APPROOT
rm bin/Darwin/lib/libgomp.1.dylib
rm bin/Darwin/lib/libgcc_s.1.dylib
# rm -r bin/Darwin/lib

cp -r ./* $APPROOT


# $APPROOT/scripts/file_downloader.py --protein dfast --cdd Cog --hmm TIGR

echo "Debug ln -s ${APPROOT}/dfast ${PREFIX}/bin/"
ln -s ${APPROOT}/dfast ${PREFIX}/bin/
ln -s ${APPROOT}/scripts/file_downloader.py ${PREFIX}/bin/


