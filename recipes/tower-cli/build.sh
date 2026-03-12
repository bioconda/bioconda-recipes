#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cp -p "$SRC_DIR"/*.jar "$TGT"

cp $RECIPE_DIR/tw.sh $TGT/tw
ln -s $TGT/tw $PREFIX/bin
chmod 0755 "${PREFIX}/bin/tw"
