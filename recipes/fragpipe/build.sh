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
cp fragpipe_source/tools/Philosopher/philosopher* "$PHILOSOPHER_DIR"
ls -l $PHILOSOPHER_DIR
linux_philosopher=$(ls "$PHILOSOPHER_DIR" | grep -v '\.exe')
ln -s "$PHILOSOPHER_DIR/$linux_philosopher" "$PREFIX/bin/philosopher"
chmod ugo+x "$PHILOSOPHER_DIR/$linux_philosopher"
