#!/bin/sh

APPROOT=$PREFIX/opt/$PKG_NAME-$PKG_VERSION

rm bin/*/aragorn
rm bin/*/barrnap
rm -r bin/Darwin/barrnap-0.8
rm bin/*/blastdbcmd
rm bin/*/blastp
rm bin/*/ghost*
rm bin/*/hmm*
rm -r bin/Darwin/lib
rm bin/*/makeblastdb
rm bin/*/mga
rm bin/*/rpsblast


mkdir -p $APPROOT
mkdir -p ${PREFIX}/bin

cp -r ./* $APPROOT

ln -s ${APPROOT}/dfast ${PREFIX}/bin/dfast
ln -s ${APPROOT}/scripts/file_downloader.py ${PREFIX}/bin/dfast_file_downloader.py
ln -s ${APPROOT}/scripts/file_downloader.py ${PREFIX}/bin/file_downloader.py
