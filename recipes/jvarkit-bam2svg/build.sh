#!/bin/bash
TOOL=bam2svg
./gradlew $TOOL

OUT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
mkdir -p $OUT
mkdir -p $PREFIX/bin
cp dist/$TOOL.jar $OUT/

cp $RECIPE_DIR/$TOOL.sh $OUT/$TOOL.sh
chmod +x $OUT/$TOOL.sh
ln -s $OUT/$TOOL.sh $PREFIX/bin
