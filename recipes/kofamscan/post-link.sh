#!/usr/bin/env bash

echo "
####################################################################################
${PKG_NAME} version ${PKG_VERSION}-${PKG_BUILDNUM} has been successfully installed!

This software needs a database which can be downloaded from ftp.genome.jp/pub/db/kofam/

For more details see ftp://ftp.genome.jp/pub/tools/kofamscan/README
 " > $PREFIX/.messages.txt
