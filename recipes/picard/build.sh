#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cp -p "$SRC_DIR"/*.jar "$TGT"

cp $RECIPE_DIR/picard.sh $TGT/picard
ln -s $TGT/picard $PREFIX/bin
chmod 0755 "${PREFIX}/bin/picard"
