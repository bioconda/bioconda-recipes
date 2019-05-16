#!/bin/bash
# set -eu -o pipefail

TARGET="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
BIN=${PREFIX}/bin
[ -d "$TARGET" ] || mkdir -p "$TARGET"
[ -d "$BIN" ] || mkdir -p "$BIN"

cd "${SRC_DIR}"
mv mirtrace ${TARGET}
mv mirtrace.jar ${TARGET}
ln -s ${TARGET}/mirtrace ${BIN}/mirtrace
ln -s ${TARGET}/mirtrace.jar ${BIN}/mirtrace.jar
chmod 0755 ${BIN}/mirtrace