#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p $TGT
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
mv chord*.jar $TGT/chord.jar

cp $RECIPE_DIR/chord.sh $TGT/chord
ln -s $TGT/chord ${PREFIX}/bin/
chmod 0755 "${PREFIX}/bin/chord"