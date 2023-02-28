#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
mv purple*.jar $TGT/purple.jar

cp $RECIPE_DIR/PURPLE.sh $TGT/PURPLE
ln -s $TGT/PURPLE $PREFIX/bin
chmod 0755 "${PREFIX}/bin/PURPLE"
