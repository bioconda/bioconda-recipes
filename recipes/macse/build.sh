#!/bin/bash
# inspired by picard build.sh

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
cp -rvp . "${TGT}"

cp $RECIPE_DIR/macse.sh $TGT/macse
ln -s $TGT/macse $PREFIX/bin
chmod 0755 "${PREFIX}/bin/macse"
