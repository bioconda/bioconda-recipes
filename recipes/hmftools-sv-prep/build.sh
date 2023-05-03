#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
mv sv-prep*.jar $TGT/sv-prep.jar

cp $RECIPE_DIR/SvPrep.sh $TGT/SvPrep
ln -s $TGT/SvPrep $PREFIX/bin
chmod 0755 "${PREFIX}/bin/SvPrep"
