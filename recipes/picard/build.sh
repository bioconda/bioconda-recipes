#!/bin/bash
set -euo pipefail

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
mkdir -p "$TGT" "$PREFIX/bin"
cp -p "$SRC_DIR"/*.jar "$TGT/"
cp "$RECIPE_DIR/picard.sh" "$TGT/picard"
chmod 0755 "$TGT/picard"
ln -s "$TGT/picard" "$PREFIX/bin/picard"
