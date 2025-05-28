#!/bin/bash

# Create directories
TARGET="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
mkdir -p "$TARGET"

# Add wrapper python script and link to unprefixed name.
cp "$RECIPE_DIR/msfragger.py" "$TARGET"
ln -s "$TARGET/msfragger.py" "$PREFIX/bin/msfragger"
chmod 0755 "${PREFIX}/bin/msfragger"

# Move and link jar.
mkdir -p "$TARGET/MSFragger-$PKG_VERSION"
unzip "download.php?token=0000000&download=Release ${PKG_VERSION}\$zip"
mv "MSFragger-${PKG_VERSION}"/* "$TARGET/MSFragger-$PKG_VERSION"
cd "$TARGET"
ln -s "MSFragger-$PKG_VERSION/MSFragger-$PKG_VERSION.jar" "MSFragger.jar"
