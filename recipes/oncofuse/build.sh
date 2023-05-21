#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
cp -r common $TGT
cp -r libs $TGT
cp Oncofuse.jar $TGT

cp $RECIPE_DIR/oncofuse.sh $TGT/oncofuse
ln -s $TGT/oncofuse $PREFIX/bin
chmod 0755 "${PREFIX}/bin/oncofuse"
