#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
mv sv-linx*.jar $TGT/sv-linx.jar

cp $RECIPE_DIR/LINX.sh $TGT/LINX
ln -s $TGT/LINX $PREFIX/bin
chmod 0755 "${PREFIX}/bin/LINX"
