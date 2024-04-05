#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
mv cobalt*.jar $TGT/cobalt.jar

cp $RECIPE_DIR/cobalt.sh $TGT/cobalt
ln -s $TGT/cobalt $PREFIX/bin
chmod 0755 "${PREFIX}/bin/cobalt"
