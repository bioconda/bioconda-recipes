#!/usr/bin/env bash

TARGET="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
BIN=${PREFIX}/bin
[ -d "$TARGET" ] || mkdir -p "$TARGET"
[ -d "$BIN" ] || mkdir -p "$BIN"

cd "${SRC_DIR}"
mv lsd-$PKG_VERSION.jar ${TARGET}
mv lsd ${TARGET}
ln -s ${TARGET}/lsd ${BIN}/lsd
chmod 0755 ${BIN}/lsd

