#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
mv teal*.jar $TGT/teal.jar

cp $RECIPE_DIR/teal.sh $TGT/teal
ln -s $TGT/teal $PREFIX/bin
chmod 0755 "${PREFIX}/bin/teal"
