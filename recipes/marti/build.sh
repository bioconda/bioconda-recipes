#!/bin/bash
set -eu -o pipefail

SHARE_DIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p "$SHARE_DIR"
mkdir -p "$PREFIX/bin"
mkdir "$SHARE_DIR/bin"
mv bin/MARTiEngine.jar "$SHARE_DIR/bin/"
mv gui "$SHARE_DIR/"
sed -i.bak -e "s|MARTI_DIR=.*|MARTI_DIR=$SHARE_DIR/bin|" bin/marti
sed -i.bak -e "s|MARTI_DIR=.*|MARTI_DIR=$SHARE_DIR/gui|" bin/marti_gui
mv bin/marti bin/marti_gui "$PREFIX/bin"

# Install npm packages for marti_gui
cd "$SHARE_DIR/gui/UI"
npm install
