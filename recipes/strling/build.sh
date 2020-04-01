#!/bin/sh
# Compile nim

cp "${CC}" "${BUILD_PREFIX}/bin/gcc"

mkdir -p $PREFIX/share
mkdir -p $PREFIX/bin
cp "$RECIPE_DIR/strling.sh" "$PREFIX/share/strling.sh"
ln -s "$PREFIX/share/strling.sh" "$PREFIX/bin/strling"
chmod +x "$PREFIX/bin/strling"

nimble install -y --verbose
chmod a+x strling
cp strling $PREFIX/share/strling
