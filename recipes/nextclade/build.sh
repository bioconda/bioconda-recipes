#!/usr/bin/env bash

ls "${SRC_DIR}"
chmod +x "${SRC_DIR}"/nextclade*
mkdir -p "${PREFIX}/bin"
mv "${SRC_DIR}"/nextclade* "${PREFIX}"/bin/nextclade

# Allow nextclade to be called as nextclade$MAJOR_VERSION
# $PKG_VERSION is in the form of MAJOR.MINOR.PATCH
MAJOR_VERSION=$(echo "$PKG_VERSION" | cut -d. -f1)
ln -s "${PREFIX}"/bin/nextclade "${PREFIX}"/bin/nextclade"$MAJOR_VERSION"