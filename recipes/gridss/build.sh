#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
mkdir -p "$TGT"
mkdir -p "${PREFIX}/bin"

cp gridss-*.jar $TGT/gridss.jar

cp $RECIPE_DIR/gridss.py $TGT/gridss
ln -s $TGT/gridss $PREFIX/bin
chmod 0755 "${PREFIX}/bin/gridss"
