#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
mv cider*.jar $TGT/cider.jar

cp $RECIPE_DIR/cider.sh $TGT/cider
ln -s $TGT/cider $PREFIX/bin
chmod 0755 "${PREFIX}/bin/cider"
