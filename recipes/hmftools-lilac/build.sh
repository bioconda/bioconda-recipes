#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
mv lilac*.jar $TGT/lilac.jar

cp $RECIPE_DIR/LILAC.sh $TGT/LILAC
ln -s $TGT/LILAC $PREFIX/bin
chmod 0755 "${PREFIX}/bin/LILAC"
