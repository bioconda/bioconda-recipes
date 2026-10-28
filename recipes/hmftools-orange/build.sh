#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
mv orange*.jar $TGT/orange.jar

cp $RECIPE_DIR/orange.sh $TGT/orange
ln -s $TGT/orange $PREFIX/bin
chmod 0755 "${PREFIX}/bin/orange"
