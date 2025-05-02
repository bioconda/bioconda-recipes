#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
mv amber*.jar $TGT/amber.jar

cp $RECIPE_DIR/amber.sh $TGT/amber
ln -s $TGT/amber $PREFIX/bin
chmod 0755 "${PREFIX}/bin/amber"
