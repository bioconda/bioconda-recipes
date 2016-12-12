#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
cp cramtools*.jar $TGT/cramtools.jar

cp $RECIPE_DIR/cramtools.sh $TGT/cramtools
ln -s $TGT/cramtools $PREFIX/bin
chmod 0755 "${PREFIX}/bin/cramtools"
