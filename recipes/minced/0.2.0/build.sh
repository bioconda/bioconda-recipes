#!/bin/sh
set -e

make

OUTDIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p "${OUTDIR}" "$PREFIX/bin"
cp minced minced.jar "${OUTDIR}/"
ln -s "${OUTDIR}/minced" "${PREFIX}/bin/"
