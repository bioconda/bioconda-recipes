#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
cp -rvp . "${TGT}"

cp $RECIPE_DIR/bis-snp.sh $TGT/bis-snp
ln -s $TGT/bis-snp $PREFIX/bin
ln -s $TGT/BisSNP-${PKG_VERSION}.jar $TGT/BisSNP.jar
chmod 0755 "${PREFIX}/bin/bis-snp"
