#!/bin/bash

install -m 755 plaScope.sh $PREFIX/bin
SHARE_DIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
DOC_DIR=$SHARE_DIR/doc
mkdir -p $SHARE_DIR
mkdir -p $DOC_DIR
install -m 644 LICENSE $SHARE_DIR
install -m 644 README.md PlaScope_supernova.png $DOC_DIR

