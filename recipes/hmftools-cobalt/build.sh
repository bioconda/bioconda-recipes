#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
mv *.jar $TGT/cobalt.jar

cp $RECIPE_DIR/COBALT.sh $TGT/COBALT
ln -s $TGT/COBALT $PREFIX/bin
chmod 0755 "${PREFIX}/bin/COBALT"
