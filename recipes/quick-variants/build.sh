#!/bin/bash
set -e

TARGET="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKV_BUILDNUM"
mkdir -p "$TARGET"
mkdir -p "$PREFIX/bin"

cd "$SRC_DIR"

# copy the .jar
cp quick-variants*.jar "$TARGET/quick-variants.jar"

# copy the runner shell script
cp "$RECIPE_DIR/quick-variants.sh" "$TARGET/quick-variants"
ln -s "$TARGET/quick-variants" "$PREFIX/bin/"
# make sure the runner is executable
chmod 0755 "$PREFIX/bin/quick-variants"
