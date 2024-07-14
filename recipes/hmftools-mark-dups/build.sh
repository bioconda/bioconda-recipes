#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
mv mark-dups*.jar $TGT/markdups.jar

cp $RECIPE_DIR/markdups.sh $TGT/markdups
ln -s $TGT/markdups $PREFIX/bin
chmod 0755 "${PREFIX}/bin/markdups"
