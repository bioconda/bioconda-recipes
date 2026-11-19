#!/bin/bash
set -euo pipefail

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
mkdir -p "$TGT" "$PREFIX/bin"
cp -p "$SRC_DIR"/*.jar "$TGT/"
# This optional native compressor was included by the historical Linux packages.
if [[ "$(uname)" == "Linux" ]]; then
    cp -p "$SRC_DIR/libIntelDeflater.so" "$TGT/"
fi
cp "$RECIPE_DIR/picard.sh" "$TGT/picard"
chmod 0755 "$TGT/picard"
ln -s "$TGT/picard" "$PREFIX/bin/picard"
