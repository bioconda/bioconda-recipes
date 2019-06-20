#!/bin/bash
./gradlew bam2wig

OUT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
mkdir -p $OUT
mkdir -p $PREFIX/bin
cp dist/bam2wig.jar $OUT/

cp $RECIPE_DIR/bam2wig.sh $OUT/bam2wig.sh
chmod +x $OUT/bam2wig.sh
ln -s $OUT/bam2wig.sh $PREFIX/bin
