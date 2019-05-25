#!/bin/bash
TOOL=msa2vcf
./gradlew $TOOL

OUT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
mkdir -p $OUT
mkdir -p $PREFIX/bin
cp dist/$TOOL.jar $OUT/

cp $RECIPE_DIR/$TOOL.py $OUT/$TOOL.py
chmod +x $OUT/$TOOL.py
ln -s $OUT/$TOOL.py $PREFIX/bin
