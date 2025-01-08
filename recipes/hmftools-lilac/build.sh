#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
mv lilac*.jar $TGT/lilac.jar

cp $RECIPE_DIR/lilac.sh $TGT/lilac
ln -s $TGT/lilac $PREFIX/bin
chmod 0755 "${PREFIX}/bin/lilac"
