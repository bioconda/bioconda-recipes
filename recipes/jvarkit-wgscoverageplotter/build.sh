#!/bin/bash -x
TOOL=wgscoverageplotter
./gradlew $TOOL

OUT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
mkdir -p $OUT
mkdir -p $PREFIX/bin
cp dist/$TOOL.jar $OUT/
JAR="$OUT/${TOOL}.jar"

sed "s^XXJARPATHXX^$JAR^" $RECIPE_DIR/${TOOL}.py > $PREFIX/bin/${TOOL}.py

chmod a+x $PREFIX/bin/${TOOL}.py
