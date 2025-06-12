#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
mv bam-tools*.jar $TGT/bamtools.jar

cp $RECIPE_DIR/bamtools.sh $TGT/bamtools
ln -s $TGT/bamtools $PREFIX/bin
chmod 0755 "${PREFIX}/bin/bamtools"
