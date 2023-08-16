#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
mv rose*.jar $TGT/rose.jar

cp $RECIPE_DIR/rose.sh $TGT/rose
ln -s $TGT/rose $PREFIX/bin
chmod 0755 "${PREFIX}/bin/rose"
