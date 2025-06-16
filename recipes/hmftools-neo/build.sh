#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
mv neo*.jar $TGT/neo.jar

cp $RECIPE_DIR/neo.sh $TGT/neo
ln -s $TGT/neo $PREFIX/bin
chmod 0755 "${PREFIX}/bin/neo"
