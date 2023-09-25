#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
mv protect*.jar $TGT/protect.jar

cp $RECIPE_DIR/protect.sh $TGT/protect
ln -s $TGT/protect $PREFIX/bin
chmod 0755 "${PREFIX}/bin/protect"
