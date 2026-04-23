#!/bin/bash
set -e

TARGET="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKV_BUILDNUM"
mkdir -p "$TARGET"
mkdir -p "$PREFIX/bin"

cd "$SRC_DIR"

# copy the .jar
cp x-mapper*.jar "$TARGET/x-mapper.jar"

# copy the runner shell script
cp "$RECIPE_DIR/x-mapper.sh" "$TARGET/x-mapper"
ln -s "$TARGET/x-mapper" "$PREFIX/bin/"
# make sure the runner is executable
chmod 0755 "$PREFIX/bin/x-mapper"
