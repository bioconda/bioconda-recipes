#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
mv qsee*.jar $TGT/qsee.jar

cp $RECIPE_DIR/qsee.sh $TGT/qsee
ln -s $TGT/qsee $PREFIX/bin
chmod 0755 "${PREFIX}/bin/qsee"
