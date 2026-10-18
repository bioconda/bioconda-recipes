#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
mv peach*.jar $TGT/peach.jar

cp $RECIPE_DIR/peach.sh $TGT/peach
ln -s $TGT/peach $PREFIX/bin
chmod 0755 "${PREFIX}/bin/peach"
