#!/bin/sh
set -e

make
make test

OUTDIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p "${OUTDIR}" "$PREFIX/bin"
cp minced minced.jar LICENSE "${OUTDIR}/"
ln -s "${OUTDIR}/minced" "${PREFIX}/bin/"
