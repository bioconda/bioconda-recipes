#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
mv sage*.jar $TGT/sage.jar

cp $RECIPE_DIR/SAGE.sh $TGT/SAGE
ln -s $TGT/SAGE $PREFIX/bin
chmod 0755 "${PREFIX}/bin/SAGE"
