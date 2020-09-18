#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
mv isofox*.jar $TGT/isofox.jar

cp $RECIPE_DIR/isofox.sh $TGT/isofox
ln -s $TGT/isofox $PREFIX/bin
chmod 0755 "${PREFIX}/bin/isofox"
