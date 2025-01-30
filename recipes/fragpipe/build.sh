#!/bin/bash

# Copy entire FragPipe installation including workflows into share location.
TARGET="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
mkdir -p "$TARGET"

cp -rp fragpipe_source/* "$TARGET"

# Copy wrapper script, which checks license keys, into bin.
mkdir "$PREFIX/bin"
cp "$RECIPE_DIR/fragpipe" "$PREFIX/bin"

# Copy Philosopher installation into share and link to bin.
PHILOSOPHER_DIR="$TARGET/philosopher"
mkdir "$PHILOSOPHER_DIR"
cp philosopher_source/philosopher philosopher_source/philosopher.yml "$PHILOSOPHER_DIR"
ln -s "$PHILOSOPHER_DIR/philosopher" "$PREFIX/bin/philosopher"
chmod ugo+x "$PHILOSOPHER_DIR/philosopher"
