#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
mv amber*.jar $TGT/amber.jar

cp $RECIPE_DIR/AMBER.sh $TGT/AMBER
ln -s $TGT/AMBER $PREFIX/bin
chmod 0755 "${PREFIX}/bin/AMBER"
