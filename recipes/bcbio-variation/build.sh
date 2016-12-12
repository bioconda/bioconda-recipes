#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"

cp bcbio.variation*standalone.jar $TGT/bcbio-variation-standalone.jar
cp $RECIPE_DIR/bcbio-variation.sh $TGT/bcbio-variation
ln -s $TGT/bcbio-variation $PREFIX/bin
chmod 0755 "${PREFIX}/bin/bcbio-variation"
