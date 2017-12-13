#!/bin/bash
set -eu -o pipefail

SHARE=share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $PREFIX/$SHARE
mkdir -p $PREFIX/bin
cp $SRC_DIR/${PKG_NAME}_v$PKG_VERSION.py $PREFIX/$SHARE/${PKG_NAME}_v$PKG_VERSION.py
echo "#!/usr/bin/env bash" >$PREFIX/bin/sccaller
echo "python2.7 $PREFIX/$SHARE/${PKG_NAME}_v$PKG_VERSION.py \$@" >>$PREFIX/bin/sccaller
chmod 0755 "${PREFIX}/bin/sccaller"
