#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
mv gripss*.jar $TGT/gripss.jar

cp $RECIPE_DIR/gripss.sh $TGT/gripss
ln -s $TGT/gripss $PREFIX/bin
chmod 0755 "${PREFIX}/bin/gripss"
