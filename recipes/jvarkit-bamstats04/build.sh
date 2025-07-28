#!/bin/bash

OUT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
mkdir -p "$OUT"
mkdir -p "$PREFIX/bin"

./gradlew bamstats04

install -v -m 0755 dist/bamstats04.jar "$OUT"
install -v -m 0755 $RECIPE_DIR/bamstats04.sh "$OUT"

ln -sf $OUT/bamstats04.sh $PREFIX/bin/
