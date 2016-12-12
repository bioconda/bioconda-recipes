#!/bin/bash

export JAVA6_HOME=${PREFIX}
TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

ant -lib lib/ant package-commands
cp -R dist/* ${TGT}

cp $RECIPE_DIR/picard.sh $TGT/picard
ln -s $TGT/picard $PREFIX/bin
chmod 0755 "${PREFIX}/bin/picard"
