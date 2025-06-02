#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
mv pave*.jar $TGT/pave.jar

cp $RECIPE_DIR/pave.sh $TGT/pave
ln -s $TGT/pave $PREFIX/bin
chmod 0755 "${PREFIX}/bin/pave"
