#!/bin/bash

set -e

rm -rf opt/

PACKAGE="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$PACKAGE" ] || mkdir -p "$PACKAGE"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

#cd "${SRC_DIR}"

cp -rvp . "${PACKAGE}"

ln -s $PACKAGE/MTBseq $PREFIX/bin/MTBseq
chmod 0755 "${PREFIX}/bin/MTBseq"
