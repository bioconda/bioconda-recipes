#!/bin/sh

APPROOT=$PREFIX/opt/$PKG_NAME-$PKG_VERSION

rm bin/*/hmm*
rm bin/*/ghost*
rm -r bin/Darwin/lib  # libs for ghostx (MacOS)

rm bin/*/aragorn
# rm bin/*/barrnap
# rm -r bin/Darwin/barrnap-0.8

# rm bin/*/CRT
# rm bin/common/CRT1.2-CLI.jar

# rm bin/*/mga

# rm bin/*/lastal
# rm bin/*/lastdb

# rm bin/*/blastp
# rm bin/*/blastdbcmd
# rm bin/*/rpsblast
# rm bin/*/makeblastdb

mkdir -p $APPROOT

cp -r ./* $APPROOT

ln -s ${APPROOT}/dfast ${PREFIX}/bin/
ln -s ${APPROOT}/scripts/file_downloader.py ${PREFIX}/bin/dfast_file_downloader.py
ln -s ${APPROOT}/scripts/file_downloader.py ${PREFIX}/bin


