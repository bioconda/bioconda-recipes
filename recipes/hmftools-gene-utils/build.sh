#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
mv gene-utils*.jar $TGT/gene-utils.jar

cp $RECIPE_DIR/gene-utils.sh $TGT/gene-utils
ln -s $TGT/gene-utils $PREFIX/bin
chmod 0755 "${PREFIX}/bin/gene-utils"
