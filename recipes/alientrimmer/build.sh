#!/bin/bash
set -eu -o pipefail

# Define vars
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/

# Generate the JAR
mv src/AlienTrimmer.java .
javac AlienTrimmer.java
echo Main-Class: AlienTrimmer > MANIFEST.MF
jar -cmvf MANIFEST.MF AlienTrimmer.jar AlienTrimmer.class
rm MANIFEST.MF AlienTrimmer.class
mv AlienTrimmer.java src/

# Move to out dir
cp AlienTrimmer.jar "$outdir/AlienTrimmer.jar"
cp "$RECIPE_DIR/alientrimmer.sh" "$outdir/alientrimmer"

# Link to env
ls -l "$outdir"
ln -s "$outdir/alientrimmer" "$PREFIX/bin"

# Make executable
chmod 0755 "${PREFIX}/bin/alientrimmer"
