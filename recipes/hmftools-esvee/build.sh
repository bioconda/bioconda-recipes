#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
mv esvee*.jar $TGT/esvee.jar

cp $RECIPE_DIR/esvee.sh $TGT/esvee
ln -s $TGT/esvee $PREFIX/bin
chmod 0755 "${PREFIX}/bin/esvee"
