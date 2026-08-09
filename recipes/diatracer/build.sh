#!/bin/bash

# Create target directory.
TARGET="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
mkdir -p "$TARGET"

# Add wrapper python script and link to name with extension.
cp "$RECIPE_DIR/diatracer.py" "$TARGET"
ln -s "$TARGET/diatracer.py" "$PREFIX/bin/diatracer"
chmod 0755 "${PREFIX}/bin/diatracer"

# Move and link jar.
mkdir -p "$TARGET/diaTracer-$PKG_VERSION"
unzip "download.php?token=0000000&download=${PKG_VERSION}%24zip"
mv "diaTracer-$PKG_VERSION/diaTracer-$PKG_VERSION.jar" "$TARGET/diaTracer-$PKG_VERSION"
cd "$TARGET"
ln -s "diaTracer-$PKG_VERSION/diaTracer-$PKG_VERSION.jar" "diaTracer.jar"
