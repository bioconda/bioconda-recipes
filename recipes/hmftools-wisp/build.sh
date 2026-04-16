#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
mv wisp*.jar $TGT/wisp.jar

cp $RECIPE_DIR/wisp.sh $TGT/wisp
ln -s $TGT/wisp $PREFIX/bin
chmod 0755 "${PREFIX}/bin/wisp"
