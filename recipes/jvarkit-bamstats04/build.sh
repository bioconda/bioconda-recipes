#!/bin/bash
./gradlew bamstats04

OUT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
mkdir -p $OUT
mkdir -p $PREFIX/bin
cp dist/bamstats04.jar $OUT/

cp $RECIPE_DIR/bamstats04.sh $OUT/bamstats04.sh
chmod +x $OUT/bamstats04.sh
ln -s $OUT/bamstats04.sh $PREFIX/bin
