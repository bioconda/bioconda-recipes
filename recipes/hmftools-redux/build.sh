#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
mv redux*.jar $TGT/redux.jar

cp $RECIPE_DIR/redux.sh $TGT/redux
ln -s $TGT/redux $PREFIX/bin
chmod 0755 "${PREFIX}/bin/redux"
