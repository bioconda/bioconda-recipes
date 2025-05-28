#!/bin/bash

# Create directories
TARGET="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
mkdir -p "$TARGET"

# Add wrapper python script and link to unprefixed name.
cp "$RECIPE_DIR/ionquant.py" "$TARGET"
ln -s "$TARGET/ionquant.py" "$PREFIX/bin/ionquant"
chmod 0755 "${PREFIX}/bin/ionquant"

# Move and link jar.
mkdir -p "$TARGET/IonQuant-$PKG_VERSION"
mv "IonQuant-$PKG_VERSION.jar" "$TARGET/IonQuant-$PKG_VERSION"
cd "$TARGET"
ln -s "IonQuant-$PKG_VERSION/IonQuant-$PKG_VERSION.jar" "IonQuant.jar"
