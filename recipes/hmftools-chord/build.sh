#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p $TGT
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
mv jar/chord*.jar $TGT/chord.jar
${R} CMD INSTALL --build src/chord/src/main/R/mutSigExtractor
${R} CMD INSTALL --build src/chord/src/main/R/CHORD

cp $RECIPE_DIR/chord.sh $TGT/chord
ln -s $TGT/chord ${PREFIX}/bin/
