#!/bin/sh

# download reference libraries
APPROOT=$PREFIX/opt/$PKG_NAME-$PKG_VERSION
python $APPROOT/scripts/file_downloader.py --protein dfast --cdd Cog --hmm TIGR
