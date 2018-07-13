#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
mkdir -p "$TGT"
mkdir -p "${PREFIX}/bin"

cp picard.jar $TGT/picard.jar

cp $RECIPE_DIR/picard.py $TGT/picard
ln -s $TGT/picard $PREFIX/bin
chmod 0755 "${PREFIX}/bin/picard"

ls -l $TGT/

