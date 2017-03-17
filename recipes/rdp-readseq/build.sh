#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

ant jar
cp -R dist/* ${TGT}

cp $RECIPE_DIR/ReadSeq.sh $TGT/ReadSeq
ln -s $TGT/ReadSeq $PREFIX/bin
chmod 0755 "${PREFIX}/bin/ReadSeq"