#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
cp -vp * "${TGT}"

cp $RECIPE_DIR/pisces.sh $TGT/pisces
ln -s $TGT/pisces $PREFIX/bin
chmod 0755 "${PREFIX}/bin/pisces"

