#!/bin/bash
set -eu -o pipefail

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"

mv bin lib $TGT
ln -s $TGT/bin/salmon $PREFIX/bin
