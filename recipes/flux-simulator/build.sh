#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
cp -rvp . "${TGT}"

ln -s $TGT/bin/flux-simulator $PREFIX/bin
chmod 0755 "${PREFIX}/bin/flux-simulator"
