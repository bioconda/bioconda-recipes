#!/bin/bash

TARGET="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
mkdir -p "$TARGET"
cp -rp fragpipe_source/* "$TARGET"

mkdir "$PREFIX/bin"
cp "$RECIPE_DIR/fragpipe" "$PREFIX/bin"

cp philosopher_source/philosopher philosopher_source/philosopher.yml "$PREFIX/bin"
chmod ugo+x "$PREFIX/bin/philosopher"
