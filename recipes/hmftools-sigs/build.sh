#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
mv sigs*.jar $TGT/sigs.jar

cp $RECIPE_DIR/sigs.sh $TGT/sigs
ln -s $TGT/sigs $PREFIX/bin
chmod 0755 "${PREFIX}/bin/sigs"
